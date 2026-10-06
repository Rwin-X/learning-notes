# Cipher.

Minimal client-side cryptography for the browser. Encrypt text, hash text or files, and generate secure random secrets. Nothing leaves the page: no backend, no analytics, no external requests, no dependencies.

## Features

- **Encrypt / Decrypt**: AES-256-GCM with a key derived from your password via PBKDF2-SHA256 (600,000 iterations). Random salt and IV for every message.
- **Hash**: SHA-256, SHA-384, SHA-512 of text or any file, with a built-in "verify against expected hash" check.
- **Generate**: passwords with unbiased character selection (rejection sampling) and entropy readout, plus a 256-bit random key in hex.
- **Six minimalist looks**, each in light and dark, switchable live (see below).
- Keyboard-navigable, no build step.

## Looks

All looks live in one file, `looks.css`. Each is a palette pair plus a handful of design tokens (typeface, headline weight and tracking, corner radius, rules, background texture). `style.css` only holds structure.

| Look | Character |
| --- | --- |
| Mono | Editorial monochrome. Hairlines, one huge headline. |
| Paper | Warm stock, serif headline, ruled lines. |
| Swiss | Square corners, 6px rule, uppercase grid. |
| Terminal | Monospace everywhere, phosphor tint, blinking cursor. |
| Soft | Low contrast, generous radii, pill controls. |
| Void | OLED black, ultra-light headline, ambient 3D helix. |

- Switch with the buttons in the header, press `L` to cycle, or open `?look=swiss` to link to one.
- The choice is remembered in `localStorage`. Light/dark follows the OS until toggled.
- Void draws a slow double helix on a single canvas (`backdrop.js`): 30 fps cap, pixel ratio capped at 1.5, no blur or shadow filters, paused when the tab is hidden, a single static frame under `prefers-reduced-motion`. It reacts to mouse, scroll and completed operations.
- Every look passes WCAG AA text contrast in both modes. `npm test` enforces it.

To add a look: add its light and dark palette blocks and tokens to `looks.css` (copy an existing look, keep the `/* look:name mode:light */` markers), add a button in `index.html`, and add the name to the list in `theme.js`. The tests fail if the three disagree or contrast drops.

## Design

| Concern | Decision |
| --- | --- |
| Primitives | Web Crypto API only. No hand-rolled cryptography, no third-party libraries. |
| Authentication | GCM tag over the ciphertext. The full header is bound as additional authenticated data, so tampering with salt, IV or iteration count fails decryption. |
| Key derivation | PBKDF2-HMAC-SHA256, 600,000 iterations (OWASP guidance for PBKDF2-SHA256). Password is NFKC-normalized so the same passphrase works across devices. |
| DoS guard | Iteration counts read from untrusted tokens are bounded to 100,000 to 5,000,000. |
| Network | Content-Security-Policy sets `connect-src 'none'` and `default-src 'none'`. The page cannot make network requests. |
| Fonts / assets | System font stack only. No CDN, no tracking surface. |

### Token format

```
base64url( "CPH1" | iterations (uint32 BE) | salt (16 B) | iv (12 B) | ciphertext + tag )
```

## Test

```bash
npm test             # Node >= 20, no dependencies
```

Covers round trips (including Unicode), random salt/IV, wrong passwords, tampering with header, salt and ciphertext, malformed tokens, SHA known-answer vectors, generator constraints, contrast for every look, look-list consistency and the CSP.

## Limitations

- Security depends on password strength. The strength meter reports an upper bound; dictionary words and patterns are weaker than it suggests. Prefer the generator or a long random passphrase.
- Browser JavaScript cannot guarantee memory wiping, and a compromised device or malicious browser extension defeats any in-browser tool.
- Serve the app yourself from a trusted origin. Anyone who can modify the served files can change what the code does.
- This project has not had an independent security audit. It uses standard primitives in a standard construction, but treat it accordingly for high-stakes secrets.

## Structure

```
index.html     markup and CSP
looks.css      all looks: palettes and design tokens
style.css      structure
theme.js       pre-paint look and theme restore
cipher.js      crypto core (browser + Node)
backdrop.js    ambient canvas for the Void look
app.js         UI wiring
test/          node:test suite (crypto, contrast, consistency)
```
