# Networking & Network+ — Zero to Professional

A complete, self-contained networking course — foundations through Network+ fluency into professional practice — built as a single interactive HTML file. No build step, no backend, no dependencies to install.

**[Open the live version →](https://claude.ai/artifact/VAEjwMx9nRzB4d6Xr7Rbob)**

## What's inside

- **10 levels**, zero knowledge → professional practice, ~44 expandable concepts. Each concept follows the same path: concept → mental model → packet-flow diagram → command → troubleshooting.
  1. Networking Foundation
  2. OSI, TCP/IP & Protocols
  3. IP Addressing & Subnetting
  4. Ethernet, Switching & VLANs
  5. Routing & Network Services
  6. Network Access, Ports & SSH
  7. Wireless, VPN & Infrastructure
  8. Network Security & Hardening
  9. Troubleshooting, Monitoring & Analysis
  10. Real-World Networking & Professional Practice
- **Protocol reference** — 23 protocols (ARP through IPsec), searchable, each with purpose/layer/transport/port/flow/security/troubleshooting.
- **Live subnet calculator** — enter any IP/CIDR, get network/broadcast/usable range instantly, plus fixed challenges and a randomized/timed practice generator.
- **8 troubleshooting scenarios** written as real tickets (symptom → causes → tools → tests → fix → verification).
- **17 projects**, beginner through capstone, each with a full brief (requirements, topology, IP plan, testing, security, portfolio value) and a "mark complete" tracker.
- **Capstone**: design and troubleshoot a secure multi-segment network.
- Cheat sheet, a 21-command Linux/Windows reference with copy buttons, a resources section, and a 30-item self-assessment checklist.
- Full-course search (`/` to open, `Esc` to close), dark/light theme, per-level and global progress tracking.

## Usage

No installation required.

```bash
git clone <this-repo>
cd <this-repo>
open networking-network-plus-zero-to-professional.html   # macOS
# or just double-click the file / drag it into a browser tab
```

To host it (GitHub Pages, Netlify, S3, anywhere static): drop the single `.html` file in and point your host at it. There's nothing else to deploy.

## How it's built

- Plain **HTML5 / CSS3 / vanilla JavaScript** — no frameworks, no npm packages, no bundler.
- All course content lives in a few in-file JavaScript data arrays (levels, protocols, ports, commands, scenarios, projects, cheat sheet, checklist); the page renders itself from that data on load.
- Progress, checklist state, and theme preference persist via `localStorage` — everything stays in the visitor's own browser, nothing is sent anywhere.
- Fonts load from Google Fonts (IBM Plex Sans / IBM Plex Mono); everything else is inlined in the one file.

## Browser support

Any evergreen browser (Chrome, Firefox, Safari, Edge). Uses `IntersectionObserver`, CSS custom properties, and `localStorage` — no polyfills included for older browsers.

## Content accuracy

Protocol behavior, ports, and command syntax are written to be technically accurate at time of writing. Certification specifics (exam codes, objectives, pricing) change — the Resources section links to CompTIA's official Network+ page directly rather than restating details that might go stale.

## License

No license has been applied yet — add a `LICENSE` file (MIT is a common choice for educational content like this) before treating this as open for reuse.

## Contributing

This is a single-file project by design. If you extend it, keep new content inside the existing `DATA` arrays in the `<script>` block rather than hand-writing new HTML blocks, so search, progress tracking, and styling stay consistent automatically.
