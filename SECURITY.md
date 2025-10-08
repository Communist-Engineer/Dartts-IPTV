# Security Policy

## Scope

**Dartt's IPTV** is an open-source IPTV player for Roku devices. This application:

- **Does NOT** host, provide, or distribute any video content
- **Does NOT** include any streams, channels, or copyrighted material
- **Only** plays user-supplied M3U/M3U8 playlists and XMLTV EPG data

Users are solely responsible for ensuring they have legal rights to access any content they configure.

---

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

---

## Reporting a Vulnerability

If you discover a security vulnerability in Dartt's IPTV, please report it responsibly:

### DO:
- Email security reports to: **security@dartts.dev** (if available) or open a **private security advisory** on GitHub
- Include:
  - Description of the vulnerability
  - Steps to reproduce
  - Potential impact
  - Suggested fix (if any)
- Allow up to 7 days for initial response

### DO NOT:
- Publicly disclose the vulnerability before it is patched
- Exploit the vulnerability maliciously
- Demand payment or ransom

---

## Security Considerations

### Network Security
- All HTTP requests use Roku's built-in `roUrlTransfer` with certificate verification
- HTTPS is recommended for all playlist and EPG URLs
- User-supplied URLs are validated to prevent injection attacks

### Data Privacy
- No personal data is collected or transmitted
- Settings and favorites are stored locally on the Roku device only
- No analytics, telemetry, or tracking

### Content Safety
- The app displays a legal notice on first run
- Users must acknowledge responsibility for their streams
- No built-in pirate feeds or copyrighted content

### Input Validation
- M3U and XMLTV parsers handle malformed input gracefully
- URL validation prevents non-HTTP(S) schemes by default
- File paths are sanitized to prevent directory traversal

---

## Known Limitations

- **DRM**: Dartt's IPTV does not support DRM-protected streams (by design)
- **External Sources**: The app cannot control or validate third-party stream legality
- **Roku Constraints**: Limited by Roku OS security and SceneGraph capabilities

---

## Responsible Disclosure Timeline

1. **Day 0**: Vulnerability reported
2. **Day 1-7**: Initial triage and acknowledgment
3. **Day 7-30**: Develop and test patch
4. **Day 30**: Public disclosure with patch release
5. **Optional**: Security advisory published on GitHub

---

## Contact

For security inquiries:
- **GitHub**: [Open a private security advisory](https://github.com/Communist-Engineer/Dartts-IPTV/security/advisories)
- **Email**: (Provide email if available)

For general issues, use the [public issue tracker](https://github.com/Communist-Engineer/Dartts-IPTV/issues).

---

Thank you for helping keep Dartt's IPTV secure! 🔒
