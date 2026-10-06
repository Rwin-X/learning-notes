// Ambient backdrop for the Void look: a slow double helix drawn with hand-rolled 3D projection.
// Cheap by design: one 2D canvas, one cached glow sprite, 30fps cap, DPR cap 1.5, no blur/shadow filters.
// Motion maps to real signals: mouse (parallax), scroll (depth), completed operations (pulse).
(function () {
  'use strict';

  var root = document.documentElement;
  var reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var N = 44;            // nodes per strand
  var R = 280;           // helix radius
  var HEIGHT = 1500;     // helix height
  var cv = null, ctx = null;
  var W = 0, H = 0;
  var raf = 0, lastT = 0, frames = 0;
  var fg = [255, 255, 255], sprite = null;
  var mx = 0, my = 0, tx = 0, ty = 0, pulse = 0;
  var yaw = 0, pit = -0.25;

  function active() { return root.getAttribute('data-look') === 'void'; }

  function readColors() {
    var hex = getComputedStyle(root).getPropertyValue('--fg').trim();
    var m = /^#([0-9a-f]{3}|[0-9a-f]{6})$/i.exec(hex);
    if (!m) return;
    var h = m[1].length === 3 ? m[1].replace(/./g, '$&$&') : m[1];
    var next = [0, 2, 4].map(function (i) { return parseInt(h.substr(i, 2), 16); });
    if (next.join() !== fg.join()) { fg = next; sprite = null; }
  }

  function getSprite() {
    if (sprite) return sprite;
    var s = 64, g = document.createElement('canvas');
    g.width = g.height = s;
    var gc = g.getContext('2d');
    var rg = gc.createRadialGradient(s / 2, s / 2, 0, s / 2, s / 2, s / 2);
    var c = fg.join(',');
    rg.addColorStop(0, 'rgba(' + c + ',.9)');
    rg.addColorStop(0.4, 'rgba(' + c + ',.22)');
    rg.addColorStop(1, 'rgba(' + c + ',0)');
    gc.fillStyle = rg;
    gc.fillRect(0, 0, s, s);
    sprite = g;
    return g;
  }

  function ensure() {
    if (cv) { cv.hidden = false; return; }
    cv = document.createElement('canvas');
    cv.id = 'bg';
    cv.setAttribute('aria-hidden', 'true');
    document.body.insertBefore(cv, document.body.firstChild);
    ctx = cv.getContext('2d');
    fit();
  }

  function fit() {
    if (!cv) return;
    var d = Math.min(window.devicePixelRatio || 1, 1.5);
    W = window.innerWidth;
    H = window.innerHeight;
    cv.width = Math.round(W * d);
    cv.height = Math.round(H * d);
    ctx.setTransform(d, 0, 0, d, 0, 0);
    if (reduce && active()) draw();
  }

  // x,y,z -> [screenX, screenY, scale, depth]
  function P(x, y, z) {
    var c = Math.cos(yaw), s = Math.sin(yaw);
    var X = x * c + z * s, Z = -x * s + z * c;
    var cp = Math.cos(pit), sp = Math.sin(pit);
    var Y = y * cp - Z * sp;
    Z = y * sp + Z * cp;
    var f = (W < 760 ? 0.7 : 1) * 900 / (1400 + Z);
    var sx = W < 760 ? 0.5 : 0.8;
    return [W * sx + X * f, H * 0.5 + Y * f, f, Z];
  }

  function draw() {
    if (!ctx) return;
    ctx.clearRect(0, 0, W, H);
    var off = -(window.scrollY || 0) * 0.15;
    var strands = [[], []];
    for (var s = 0; s < 2; s++) {
      for (var i = 0; i < N; i++) {
        var a = i * 0.32 + s * Math.PI;
        strands[s].push(P(Math.cos(a) * R, (i / N - 0.5) * HEIGHT + off, Math.sin(a) * R));
      }
    }
    var boost = 0.6 + pulse * 0.4;

    // strands
    ctx.lineWidth = 1;
    ctx.strokeStyle = 'rgb(' + fg.join(',') + ')';
    ctx.globalAlpha = (0.1 + pulse * 0.12);
    for (s = 0; s < 2; s++) {
      ctx.beginPath();
      ctx.moveTo(strands[s][0][0], strands[s][0][1]);
      for (i = 1; i < N; i++) ctx.lineTo(strands[s][i][0], strands[s][i][1]);
      ctx.stroke();
    }
    // rungs
    ctx.globalAlpha = 0.07 + pulse * 0.08;
    ctx.beginPath();
    for (i = 0; i < N; i += 3) {
      ctx.moveTo(strands[0][i][0], strands[0][i][1]);
      ctx.lineTo(strands[1][i][0], strands[1][i][1]);
    }
    ctx.stroke();
    // nodes
    var g = getSprite();
    for (s = 0; s < 2; s++) {
      for (i = 0; i < N; i++) {
        var p = strands[s][i];
        var near = 1 - Math.max(0, Math.min(1, (p[3] + R) / (2 * R)));
        var size = (2 + 3 * near) * p[2] * 6;
        ctx.globalAlpha = (0.12 + 0.45 * near) * boost;
        ctx.drawImage(g, p[0] - size / 2, p[1] - size / 2, size, size);
      }
    }
    // pulse ring, fired by completed operations
    if (pulse > 0.03) {
      var c = P(0, off, 0);
      ctx.globalAlpha = pulse * 0.25;
      ctx.beginPath();
      ctx.arc(c[0], c[1], R * c[2] * (1 + (1 - pulse) * 0.7), 0, 6.2832);
      ctx.stroke();
    }
    ctx.globalAlpha = 1;
  }

  function frame(ts) {
    raf = window.requestAnimationFrame(frame);
    if (ts - lastT < 33) return; // ~30fps
    lastT = ts;
    frames++;
    if (frames % 30 === 0) readColors();
    tx += (mx - tx) * 0.06;
    ty += (my - ty) * 0.06;
    yaw = ts * 0.00012 + tx * 0.35;
    pit = -0.25 + ty * 0.15;
    pulse *= 0.94;
    draw();
  }

  function stop() {
    if (raf) { window.cancelAnimationFrame(raf); raf = 0; }
    if (cv) cv.hidden = true;
  }

  function sync() {
    if (!active() || document.hidden) { stop(); return; }
    ensure();
    readColors();
    if (reduce) { draw(); return; }
    if (!raf) raf = window.requestAnimationFrame(frame);
  }

  window.addEventListener('mousemove', function (e) {
    mx = (e.clientX / (W || 1)) * 2 - 1;
    my = (e.clientY / (H || 1)) * 2 - 1;
  }, { passive: true });
  window.addEventListener('resize', fit);
  window.addEventListener('cipher:pulse', function () { pulse = 1; });
  document.addEventListener('visibilitychange', sync);
  new MutationObserver(function () { sprite = null; sync(); })
    .observe(root, { attributes: true, attributeFilter: ['data-look', 'data-theme'] });

  sync();
})();
