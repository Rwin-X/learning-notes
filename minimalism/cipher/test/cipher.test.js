'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const C = require('../cipher.js');

const FAST = 100000; // minimum accepted iteration count, keeps tests quick

test('encrypt/decrypt round trip (unicode)', async () => {
  const msg = 'Hello — سلام \u{1F512}';
  const token = await C.encrypt(msg, 'correct horse battery staple', FAST);
  assert.equal(await C.decrypt(token, 'correct horse battery staple'), msg);
});

test('same input produces different tokens (random salt/IV)', async () => {
  const a = await C.encrypt('x', 'pw', FAST);
  const b = await C.encrypt('x', 'pw', FAST);
  assert.notEqual(a, b);
});

test('wrong password fails', async () => {
  const token = await C.encrypt('secret', 'right', FAST);
  await assert.rejects(C.decrypt(token, 'wrong'), /wrong password or modified data/);
});

test('tampering with ciphertext, salt or header fails', async () => {
  const token = await C.encrypt('secret', 'pw', FAST);
  const raw = Buffer.from(token, 'base64url');
  for (const idx of [10, 30, raw.length - 1]) {
    const bad = Buffer.from(raw);
    bad[idx] ^= 1;
    await assert.rejects(C.decrypt(bad.toString('base64url'), 'pw'));
  }
});

test('garbage and truncated tokens are rejected', async () => {
  await assert.rejects(C.decrypt('not a token!!', 'pw'), /not a valid/);
  const token = await C.encrypt('secret', 'pw', FAST);
  await assert.rejects(C.decrypt(token.slice(0, 20), 'pw'), /not a valid/);
});

test('iteration count outside allowed range is rejected', async () => {
  const token = await C.encrypt('secret', 'pw', FAST);
  const raw = Buffer.from(token, 'base64url');
  raw.writeUInt32BE(0xffffffff, 4);
  await assert.rejects(C.decrypt(raw.toString('base64url'), 'pw'), /Unsupported/);
});

test('SHA known-answer vectors', async () => {
  const abc = new TextEncoder().encode('abc');
  assert.equal(
    await C.digest('SHA-256', abc),
    'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'
  );
  assert.equal(
    await C.digest('SHA-512', abc),
    'ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a' +
      '2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f'
  );
});

test('generatePassword respects length and character sets', () => {
  const pw = C.generatePassword(64, { lower: true, upper: false, digits: true, symbols: false });
  assert.equal(pw.length, 64);
  assert.match(pw, /^[a-z0-9]+$/);
  assert.match(pw, /[a-z]/);
  assert.match(pw, /[0-9]/);
  assert.throws(() => C.generatePassword(10, {}), /at least one/);
});

test('randomKeyHex returns 64 hex chars for 32 bytes', () => {
  assert.match(C.randomKeyHex(32), /^[0-9a-f]{64}$/);
  assert.notEqual(C.randomKeyHex(32), C.randomKeyHex(32));
});
