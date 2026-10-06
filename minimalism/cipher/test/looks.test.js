'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const read = (f) => fs.readFileSync(path.join(__dirname, '..', f), 'utf8');
const css = read('looks.css');
const html = read('index.html');
const themeJs = read('theme.js');

function lum(hex) {
  const [r, g, b] = [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16) / 255);
  const f = (c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
  return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b);
}
const ratio = (a, b) => {
  const [hi, lo] = [lum(a), lum(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
};

// Segments start at "/* look:NAME mode:MODE */" markers.
const parts = css.split(/\/\* look:(\w+) mode:(light|dark) \*\//).slice(1);
const palettes = [];
for (let i = 0; i < parts.length; i += 3) {
  const body = parts[i + 2];
  const get = (v) => (body.match(new RegExp(`${v}:\\s*(#[0-9a-fA-F]{6})`)) || [])[1];
  palettes.push({ look: parts[i], mode: parts[i + 1], bg: get('--bg'), fg: get('--fg'), mut: get('--mut'), card: get('--card') });
}

const buttonLooks = [...html.matchAll(/class="look"[^>]*data-look="(\w+)"/g)].map((m) => m[1]);
const jsLooks = (themeJs.match(/LOOKS = \[([^\]]+)\]/)[1].match(/\w+/g)) || [];

test('every look defines a complete light and dark palette', () => {
  assert.equal(palettes.length, buttonLooks.length * 2);
  for (const p of palettes) {
    for (const k of ['bg', 'fg', 'mut', 'card']) assert.ok(p[k], `${p.look}/${p.mode} missing ${k}`);
  }
});

test('WCAG AA text contrast holds for every look in both modes', () => {
  for (const p of palettes) {
    assert.ok(ratio(p.fg, p.bg) >= 7, `${p.look}/${p.mode} fg on bg`);
    assert.ok(ratio(p.fg, p.card) >= 7, `${p.look}/${p.mode} fg on card`);
    assert.ok(ratio(p.mut, p.bg) >= 4.5, `${p.look}/${p.mode} muted on bg = ${ratio(p.mut, p.bg).toFixed(2)}`);
    assert.ok(ratio(p.mut, p.card) >= 4.5, `${p.look}/${p.mode} muted on card = ${ratio(p.mut, p.card).toFixed(2)}`);
  }
});

test('switcher buttons, theme.js and looks.css agree on the look list', () => {
  const inCss = [...new Set(palettes.map((p) => p.look))].sort();
  assert.deepEqual([...buttonLooks].sort(), inCss);
  assert.deepEqual([...jsLooks].sort(), inCss);
});

test('CSP forbids network access and inline code', () => {
  const csp = html.match(/Content-Security-Policy" content="([^"]+)"/)[1];
  assert.match(csp, /connect-src 'none'/);
  assert.match(csp, /script-src 'self'(?!.*unsafe)/);
  assert.doesNotMatch(html, /\sstyle="/);
  assert.doesNotMatch(html, /<script(?![^>]*\ssrc=)/);
});
