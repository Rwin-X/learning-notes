(function () {
  'use strict';

  var C = window.Cipher;
  var $ = function (s) { return document.querySelector(s); };
  var $$ = function (s) { return Array.prototype.slice.call(document.querySelectorAll(s)); };

  /* ---------- theme ---------- */
  var root = document.documentElement;
  function currentTheme() {
    return root.getAttribute('data-theme') ||
      (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  }
  function themeLabel() { $('#theme').textContent = currentTheme() === 'dark' ? 'Light' : 'Dark'; }
  $('#theme').addEventListener('click', function () {
    var next = currentTheme() === 'dark' ? 'light' : 'dark';
    root.setAttribute('data-theme', next);
    try { localStorage.setItem('cipher-theme', next); } catch (e) {}
    themeLabel();
  });
  themeLabel();

  /* ---------- looks ---------- */
  var looks = $$('.look');
  function setLook(name, persist) {
    root.setAttribute('data-look', name);
    looks.forEach(function (b) { b.setAttribute('aria-pressed', String(b.dataset.look === name)); });
    if (persist) { try { localStorage.setItem('cipher-look', name); } catch (e) {} }
  }
  looks.forEach(function (b) {
    b.addEventListener('click', function () { setLook(b.dataset.look, true); });
  });
  document.addEventListener('keydown', function (e) {
    if ((e.key !== 'l' && e.key !== 'L') || e.metaKey || e.ctrlKey || e.altKey) return;
    var t = e.target;
    if (t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' || t.isContentEditable)) return;
    var names = looks.map(function (b) { return b.dataset.look; });
    setLook(names[(names.indexOf(root.getAttribute('data-look')) + 1) % names.length], true);
  });
  setLook(root.getAttribute('data-look') || 'mono', false);

  // Completed operations nudge the Void backdrop (no-op in other looks).
  function pulse() { window.dispatchEvent(new CustomEvent('cipher:pulse')); }

  /* ---------- tabs ---------- */
  var tabs = $$('[role="tab"]');
  function select(id) {
    tabs.forEach(function (t) {
      var on = t.dataset.tab === id;
      t.setAttribute('aria-selected', String(on));
      t.tabIndex = on ? 0 : -1;
    });
    $$('[role="tabpanel"]').forEach(function (p) { p.hidden = p.id !== 'panel-' + id; });
  }
  tabs.forEach(function (t, i) {
    t.addEventListener('click', function () { select(t.dataset.tab); });
    t.addEventListener('keydown', function (e) {
      var d = e.key === 'ArrowRight' ? 1 : e.key === 'ArrowLeft' ? -1 : 0;
      if (!d) return;
      var n = tabs[(i + d + tabs.length) % tabs.length];
      n.focus();
      select(n.dataset.tab);
    });
  });

  /* ---------- helpers ---------- */
  function copy(text, statusEl, label) {
    if (!text) return;
    var done = function () { statusEl.textContent = (label || 'Copied') + '.'; };
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(done, function () { statusEl.textContent = 'Copy failed.'; });
    } else {
      var ta = document.createElement('textarea');
      ta.value = text;
      document.body.appendChild(ta);
      ta.select();
      try { document.execCommand('copy'); done(); } catch (e) { statusEl.textContent = 'Copy failed.'; }
      document.body.removeChild(ta);
    }
  }

  /* ---------- encrypt / decrypt ---------- */
  var inEl = $('#in'), pwEl = $('#pw'), outEl = $('#out'), encStatus = $('#enc-status');
  var btnEnc = $('#btn-enc'), btnDec = $('#btn-dec');

  function strengthLabel(bits) {
    return bits < 40 ? 'weak' : bits < 64 ? 'fair' : bits < 90 ? 'strong' : 'very strong';
  }
  pwEl.addEventListener('input', function () {
    var bits = C.estimateBits(pwEl.value);
    $('#pw-fill').style.width = Math.min(100, (bits / 128) * 100) + '%';
    $('#pw-info').textContent = bits ? 'up to ' + bits + ' bits · ' + strengthLabel(bits) + ' (upper bound)' : '';
  });
  $('#pw-toggle').addEventListener('click', function () {
    var hidden = pwEl.type === 'password';
    pwEl.type = hidden ? 'text' : 'password';
    $('#pw-toggle').textContent = hidden ? 'Hide' : 'Show';
  });

  function busy(on) { btnEnc.disabled = on; btnDec.disabled = on; }

  async function run(mode) {
    var text = inEl.value, pw = pwEl.value;
    if (!text) { encStatus.textContent = 'Input is empty.'; return; }
    if (!pw) { encStatus.textContent = 'Password required.'; return; }
    busy(true);
    encStatus.textContent = 'Deriving key…';
    try {
      var res = mode === 'enc' ? await C.encrypt(text, pw) : await C.decrypt(text.trim(), pw);
      outEl.value = res;
      encStatus.textContent = mode === 'enc' ? 'Encrypted.' : 'Decrypted and authenticated.';
      pulse();
    } catch (err) {
      outEl.value = '';
      encStatus.textContent = err.message;
    } finally {
      busy(false);
    }
  }
  btnEnc.addEventListener('click', function () { run('enc'); });
  btnDec.addEventListener('click', function () { run('dec'); });
  $('#btn-copy').addEventListener('click', function () { copy(outEl.value, encStatus); });
  $('#btn-clear').addEventListener('click', function () {
    inEl.value = ''; pwEl.value = ''; outEl.value = '';
    $('#pw-fill').style.width = '0'; $('#pw-info').textContent = '';
    encStatus.textContent = 'Cleared.';
  });

  /* ---------- hash ---------- */
  var ALGOS = [['SHA-256', '#h-256'], ['SHA-384', '#h-384'], ['SHA-512', '#h-512']];
  var lastHashes = {};
  var hashToken = 0;

  async function hashBytes(bytes, info) {
    var token = ++hashToken;
    var results = await Promise.all(ALGOS.map(function (a) { return C.digest(a[0], bytes); }));
    if (token !== hashToken) return; // a newer request superseded this one
    ALGOS.forEach(function (a, i) {
      var el = $(a[1]);
      el.textContent = results[i];
      el.classList.remove('empty');
      lastHashes[a[0]] = results[i];
    });
    $('#h-info').textContent = info;
    verify();
    pulse();
  }
  function resetHashes() {
    hashToken++;
    lastHashes = {};
    ALGOS.forEach(function (a) { var el = $(a[1]); el.textContent = '—'; el.classList.add('empty'); });
    $('#h-info').textContent = '';
    verify();
  }
  function verify() {
    var want = $('#h-verify').value.trim().toLowerCase().replace(/\s+/g, '');
    var el = $('#h-match');
    if (!want) { el.textContent = ''; return; }
    var hit = Object.keys(lastHashes).filter(function (k) { return lastHashes[k] === want; })[0];
    el.textContent = hit ? 'Match · ' + hit : Object.keys(lastHashes).length ? 'No match.' : '';
  }
  $('#h-verify').addEventListener('input', verify);

  $('#h-in').addEventListener('input', function (e) {
    $('#h-file').value = '';
    var v = e.target.value;
    if (!v) { resetHashes(); return; }
    var bytes = new TextEncoder().encode(v);
    hashBytes(bytes, bytes.length + ' bytes (UTF-8)');
  });
  $('#h-file').addEventListener('change', async function (e) {
    var f = e.target.files[0];
    if (!f) { resetHashes(); return; }
    $('#h-in').value = '';
    $('#h-info').textContent = 'Reading ' + f.name + '…';
    try {
      var buf = new Uint8Array(await f.arrayBuffer());
      await hashBytes(buf, f.name + ' · ' + buf.length + ' bytes');
    } catch (err) {
      $('#h-info').textContent = 'Could not read file.';
    }
  });
  $('#h-copy').addEventListener('click', function () { copy(lastHashes['SHA-256'], $('#h-info')); });

  /* ---------- generate ---------- */
  var gOut = $('#g-out'), gStatus = $('#g-status');
  function sets() {
    return {
      lower: $('#g-lower').checked,
      upper: $('#g-upper').checked,
      digits: $('#g-digits').checked,
      symbols: $('#g-symbols').checked,
    };
  }
  function genPassword() {
    var len = parseInt($('#g-len').value, 10);
    $('#g-len-val').textContent = len;
    try {
      var s = sets();
      gOut.value = C.generatePassword(len, s);
      var bits = Math.round(len * Math.log2(C.poolOf(s).length));
      $('#g-bits').textContent = bits;
      $('#g-fill').style.width = Math.min(100, (bits / 256) * 100) + '%';
      gStatus.textContent = '';
    } catch (err) {
      gOut.value = '';
      $('#g-bits').textContent = '0';
      $('#g-fill').style.width = '0';
      gStatus.textContent = err.message;
    }
  }
  function genKey() { $('#k-out').value = C.randomKeyHex(32); }

  $('#g-regen').addEventListener('click', function () { genPassword(); pulse(); });
  $('#g-len').addEventListener('input', genPassword);
  ['#g-lower', '#g-upper', '#g-digits', '#g-symbols'].forEach(function (id) {
    $(id).addEventListener('change', genPassword);
  });
  $('#g-copy').addEventListener('click', function () { copy(gOut.value, gStatus); });
  $('#k-regen').addEventListener('click', function () { genKey(); pulse(); });
  $('#k-copy').addEventListener('click', function () { copy($('#k-out').value, gStatus); });

  genPassword();
  genKey();
})();
