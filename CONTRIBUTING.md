# Contributing to Dartt's IPTV

Thank you for your interest in contributing! This document outlines the process and guidelines.

---

## Code of Conduct

This project adheres to a simple code of conduct:

- Be respectful and constructive
- Welcome newcomers and help them learn
- Focus on collaboration and quality
- No harassment, discrimination, or malicious behavior

Violations may result in removal from the project.

---

## How to Contribute

### Reporting Bugs

1. Check [existing issues](https://github.com/Communist-Engineer/Dartts-IPTV/issues) to avoid duplicates
2. Create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - Roku device model and OS version
   - Logs from telnet debug console (if applicable)

### Suggesting Features

1. Open an issue with the `enhancement` label
2. Describe the feature and use case
3. Explain why it benefits users
4. Be open to feedback and iteration

### Submitting Pull Requests

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following the style guide
4. **Test thoroughly**:
   - Build and sideload to a Roku device
   - Verify no regressions
   - Add unit tests if applicable
5. **Commit** with clear messages (see below)
6. **Push** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Open a Pull Request** against `main`
   - Reference related issues
   - Describe what changed and why
   - Include screenshots/videos if relevant

---

## Development Setup

See [README.md](README.md#development) for prerequisites and build instructions.

### Quick Start

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/Dartts-IPTV.git
cd Dartts-IPTV

# Build and test
make dev ROKU_IP=192.168.1.100
```

---

## Code Style Guidelines

### BrightScript

- **Indentation**: 4 spaces (no tabs)
- **Naming**:
  - Functions: `PascalCase` (e.g., `ParseM3U`)
  - Variables: `camelCase` (e.g., `channelList`)
  - Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRIES`)
- **Comments**:
  - Use `'` for single-line comments
  - Explain "why", not "what"
  - Document complex logic
- **Error Handling**:
  - Always check for `invalid`
  - Log errors with `LogError()`
  - Fail gracefully, never crash

### SceneGraph XML

- **Indentation**: 2 spaces
- **Component Names**: `PascalCase`
- **Field IDs**: `camelCase`
- **Close tags** properly
- **Use `entry` attribute** to avoid global name conflicts

### Example

```brightscript
function ParseM3U(content as string) as object
    result = {
        channels: [],
        groups: CreateObject("roAssociativeArray"),
        errors: []
    }
    
    if content = invalid or Len(content) = 0 then
        result.errors.Push("Empty playlist")
        return result
    end if
    
    ' Parse lines...
    return result
end function
```

---

## Commit Message Guidelines

Follow **Conventional Commits**:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style (formatting, no logic change)
- `refactor`: Code restructuring (no behavior change)
- `test`: Add or update tests
- `chore`: Build, tooling, dependencies

### Examples

```
feat(parser): add support for #EXTGRP directive

Implements parsing of #EXTGRP to override group-title attribute.
Useful for non-standard M3U files.

Closes #42
```

```
fix(player): handle missing subtitle tracks gracefully

Previously crashed when SubtitleTracks was undefined.
Now checks for existence before accessing.

Fixes #58
```

---

## Testing Requirements

All contributions should include:

- [ ] **Unit tests** (if adding parsers or utility functions)
- [ ] **Manual testing** on a real Roku device
- [ ] **No lint errors** (validate with `make validate`)
- [ ] **No crashes** in debug console

Run tests before submitting:

```bash
make test
make integration-test ROKU_IP=192.168.1.100
```

---

## Documentation

Update relevant documentation:

- `README.md` - User-facing features
- `docs/` - Detailed guides
- Code comments - Complex logic
- Commit messages - Clear change descriptions

---

## Release Process

(For maintainers)

1. Update `manifest` version (`major`, `minor`, `build`)
2. Update `CHANGELOG.md`
3. Create a git tag: `git tag v1.0.1`
4. Push: `git push origin v1.0.1`
5. Build release ZIP: `make package`
6. Create GitHub release with artifact

---

## Questions?

### Questions

- Open a [Discussion](https://github.com/Communist-Engineer/Dartts-IPTV/discussions)
- Comment on existing issues
- Reach out to maintainers

---

Thank you for contributing to Dartt's IPTV! 🎉
