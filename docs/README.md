# Mindset iOS Documentation

Welcome to the Mindset iOS app documentation! This directory contains guides, architecture documentation, and troubleshooting resources organized for easy reference.

---

## 📁 Directory Structure

```
docs/
├── README.md (this file)
├── architecture/      # System design and architecture decisions
├── setup/            # Initial setup and configuration guides
├── guides/           # Implementation guides and how-tos
└── troubleshooting/  # Common issues and solutions
```

---

## 📚 Documentation Index

### 🏗️ Architecture (`architecture/`)

**System design, patterns, and architectural decisions:**

- **[AUTH_DECOUPLED_ARCHITECTURE.md](architecture/AUTH_DECOUPLED_ARCHITECTURE.md)**
  - Clean architecture for authentication
  - Protocol-based auth abstraction
  - Firebase integration without tight coupling

- **[ONBOARDING_ARCHITECTURE.md](architecture/ONBOARDING_ARCHITECTURE.md)**
  - Onboarding flow design (14 steps)
  - Quiz-driven personalization
  - Coordinator pattern implementation

---

### ⚙️ Setup (`setup/`)

**Initial configuration and environment setup:**

- **[FIREBASE_SETUP.md](setup/FIREBASE_SETUP.md)**
  - Firebase project configuration
  - Authentication providers setup
  - Firestore rules and collections

---

### 📖 Guides (`guides/`)

**Step-by-step implementation guides:**

- **[GOOGLE_SIGNIN_VIA_FIREBASE.md](guides/GOOGLE_SIGNIN_VIA_FIREBASE.md)**
  - Google Sign In using Firebase's built-in OAuth flow
  - How to avoid GoogleSignIn SDK
  - ASWebAuthenticationSession configuration

- **[GOOGLE_SIGNIN_SUCCESS.md](guides/GOOGLE_SIGNIN_SUCCESS.md)**
  - Success checklist for Google Sign In
  - Testing steps
  - Expected behavior

---

### 🔧 Troubleshooting (`troubleshooting/`)

**Common issues and their solutions:**

- **[FIX_ANONYMOUS_SIGNIN.md](troubleshooting/FIX_ANONYMOUS_SIGNIN.md)**
  - Fix "Sign In Error" for anonymous authentication
  - Enable Anonymous Auth in Firebase Console
  - Debug overlay usage for auth errors

---

## 🚀 Quick Start

New to the project? Start here:

1. Read `Context.md` in the root (project overview and tech stack)
2. Follow [FIREBASE_SETUP.md](setup/FIREBASE_SETUP.md) to configure Firebase
3. Review [AUTH_DECOUPLED_ARCHITECTURE.md](architecture/AUTH_DECOUPLED_ARCHITECTURE.md) to understand auth flow
4. Check [troubleshooting/](troubleshooting/) if you encounter issues

---

## 🎯 Project Context

**Main project documentation:**
- **[../Context.md](../Context.md)** - Complete project overview, MLP roadmap, tech stack, design system
- **[../.cursorrules](../.cursorrules)** - AI assistant coding rules and conventions

---

## 📝 Adding New Documentation

When creating new documentation:

1. **Choose the right category:**
   - `architecture/` - Design decisions, patterns, system structure
   - `setup/` - Configuration, installation, environment setup
   - `guides/` - How-to guides, implementation tutorials
   - `troubleshooting/` - Common errors, debugging, fixes

2. **Use clear naming:**
   - Architecture: `[TOPIC]_ARCHITECTURE.md`
   - Setup: `[SERVICE]_SETUP.md`
   - Guides: `[FEATURE]_GUIDE.md`
   - Troubleshooting: `FIX_[ISSUE].md`

3. **Update this README** with a link and brief description

---

## 🛠️ Documentation Standards

- Use emoji for visual scanning (🔍 Problem, ✅ Solution, ⚠️ Warning, etc.)
- Include code examples with syntax highlighting
- Add "Related Files" section linking to relevant source code
- Keep guides focused and actionable
- Use tables for comparison/reference data

---

## 📞 Need Help?

- Check the [troubleshooting/](troubleshooting/) directory first
- Review related architecture docs for context
- Enable the debug overlay in the app for real-time logs
- Search for specific errors in Firebase documentation

---

**Last Updated:** February 2026
