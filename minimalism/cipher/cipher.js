/*! Cipher core: AES-256-GCM + PBKDF2-SHA256 on the Web Crypto API. Zero dependencies. */
(function (root, factory) {
  const api = factory();
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.Cipher = api;
})(typeof window !== 'undefined' ? window : globalThis, function () {
  'use strict';

  const subtle = globalThis.crypto && globalThis.crypto.subtle;
  const MAGIC = [0x43, 0x50, 0x48, 0x31]; // "CPH1"
  const SALT_LEN = 16;
  const IV_LEN = 12;
  const TAG_LEN = 16;
  const HEADER_LEN = 4 + 4 + SALT_LEN + IV_LEN; // magic | iterations | salt | iv
  const DEFAULT_ITER = 600000;
  const MIN_ITER = 100000;
  const MAX_ITER = 5000000;

  const SETS = {
    lower: 'abcdefghijklmnopqrstuvwxyz',
    upper: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    digits: '0123456789',
    symbols: '!@#$%^&*()-_=+[]{};:,.?/',
  };

  const encoder = new TextEncoder();
  const decoder = new TextDecoder('utf-8', { fatal: true });

  function need() {
    if (!subtle) throw new Error('Web Crypto is unavailable. Use HTTPS or localhost.');
  }

  function randomBytes(n) {
    return globalThis.crypto.getRandomValues(new Uint8Array(n));
  }

  // Uniform integer in [0, max) using rejection sampling (no modulo bias).
  function randomInt(max) {
    const limit = Math.floor(0x100000000 / max) * max;
    const buf = new Uint32Array(1);
    do globalThis.crypto.getRandomValues(buf);
    while (buf[0] >= limit);
    return buf[0] % max;
  }

  function toHex(bytes) {
    return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
  }

  function toB64u(bytes) {
    let s = '';
    for (let i = 0; i < bytes.length; i += 0x8000) {
      s += String.fromCharCode.apply(null, bytes.subarray(i, i + 0x8000));
    }
    return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  }

  function fromB64u(str) {
    const s = str.replace(/\s+/g, '').replace(/-/g, '+').replace(/_/g, '/');
    const bin = atob(s + '='.repeat((4 - (s.length % 4)) % 4));
    const out = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
    return out;
  }

  async function deriveKey(password, salt, iterations) {
    const material = await subtle.importKey(
      'raw',
      encoder.encode(password.normalize('NFKC')),
      'PBKDF2',
      false,
      ['deriveKey']
    );
    return subtle.deriveKey(
      { name: 'PBKDF2', salt, iterations, hash: 'SHA-256' },
      material,
      { name: 'AES-GCM', length: 256 },
      false,
      ['encrypt', 'decrypt']
    );
  }

  // token = base64url( "CPH1" | iterations(u32 BE) | salt(16) | iv(12) | ciphertext+tag )
  // The whole header is bound as AES-GCM additional data, so any tampering fails authentication.
  async function encrypt(plaintext, password, iterations = DEFAULT_ITER) {
    need();
    if (!password) throw new Error('Password required.');
    const salt = randomBytes(SALT_LEN);
    const iv = randomBytes(IV_LEN);
    const header = new Uint8Array(HEADER_LEN);
    header.set(MAGIC, 0);
    new DataView(header.buffer).setUint32(4, iterations, false);
    header.set(salt, 8);
    header.set(iv, 8 + SALT_LEN);
    const key = await deriveKey(password, salt, iterations);
    const ct = new Uint8Array(
      await subtle.encrypt({ name: 'AES-GCM', iv, additionalData: header }, key, encoder.encode(plaintext))
    );
    const out = new Uint8Array(HEADER_LEN + ct.length);
    out.set(header, 0);
    out.set(ct, HEADER_LEN);
    return toB64u(out);
  }

  async function decrypt(token, password) {
    need();
    if (!password) throw new Error('Password required.');
    let raw;
    try {
      raw = fromB64u(token);
    } catch (_) {
      throw new Error('Input is not a valid Cipher token.');
    }
    if (raw.length < HEADER_LEN + TAG_LEN || MAGIC.some((b, i) => raw[i] !== b)) {
      throw new Error('Input is not a valid Cipher token.');
    }
    const iterations = new DataView(raw.buffer, raw.byteOffset).getUint32(4, false);
    if (iterations < MIN_ITER || iterations > MAX_ITER) {
      throw new Error('Unsupported or corrupted header.');
    }
    const header = raw.slice(0, HEADER_LEN);
    const salt = raw.slice(8, 8 + SALT_LEN);
    const iv = raw.slice(8 + SALT_LEN, HEADER_LEN);
    const ct = raw.slice(HEADER_LEN);
    const key = await deriveKey(password, salt, iterations);
    let pt;
    try {
      pt = await subtle.decrypt({ name: 'AES-GCM', iv, additionalData: header }, key, ct);
    } catch (_) {
      throw new Error('Decryption failed: wrong password or modified data.');
    }
    return decoder.decode(pt);
  }

  async function digest(algo, bytes) {
    need();
    return toHex(new Uint8Array(await subtle.digest(algo, bytes)));
  }

  function poolOf(enabled) {
    return Object.keys(SETS)
      .filter((k) => enabled[k])
      .map((k) => SETS[k])
      .join('');
  }

  function generatePassword(length, enabled) {
    const picked = Object.keys(SETS).filter((k) => enabled[k]);
    if (!picked.length) throw new Error('Select at least one character set.');
    if (length < picked.length) throw new Error('Length is too short for the selected sets.');
    const pool = poolOf(enabled);
    const out = picked.map((k) => SETS[k][randomInt(SETS[k].length)]);
    while (out.length < length) out.push(pool[randomInt(pool.length)]);
    for (let i = out.length - 1; i > 0; i--) {
      const j = randomInt(i + 1);
      [out[i], out[j]] = [out[j], out[i]];
    }
    return out.join('');
  }

  function randomKeyHex(bytes = 32) {
    return toHex(randomBytes(bytes));
  }

  // Upper bound on password strength; dictionary words and patterns are weaker than this.
  function estimateBits(s) {
    if (!s) return 0;
    let pool = 0;
    if (/[a-z]/.test(s)) pool += 26;
    if (/[A-Z]/.test(s)) pool += 26;
    if (/\d/.test(s)) pool += 10;
    if (/[^A-Za-z0-9]/.test(s)) pool += 33;
    return Math.round(s.length * Math.log2(pool || 1));
  }

  return {
    SETS,
    DEFAULT_ITER,
    encrypt,
    decrypt,
    digest,
    generatePassword,
    randomKeyHex,
    estimateBits,
    poolOf,
  };
});
