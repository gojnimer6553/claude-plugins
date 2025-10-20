# Claude Code Plugins

A collection of useful plugins for Claude Code to enhance your development workflow.

## 🔌 Available Plugins

### 1. **Git Commit Plugin**
Organized git commits with conventional commit format and intelligent context-based grouping.

**Features:**
- 🎯 Conventional Commits format
- 📁 Context-based file grouping
- 🤖 Smart commit type suggestions
- 🎨 Interactive prompts
- 🚀 Optional push support
- ✨ Clean messages (no footers)

**Usage:**
```bash
./git-commit.sh commit              # Create commits
./git-commit.sh commit-push         # Commit and push
./git-commit.sh analyze             # Analyze changes
```

**Documentation:** [README-git-commit.md](./README-git-commit.md)

---

### 2. **GitHub Scaffold Plugin**
Clone and scaffold projects from GitHub repositories with support for subdirectories and branches.

**Features:**
- 🌲 Subdirectory support
- 🌿 Branch selection
- 👁️ Preview mode
- 📦 Selective downloads
- 🎨 Beautiful tree output
- ⚡ GitHub API integration

**Usage:**
```bash
./github-scaffold.sh clone <url>       # Clone repo/subdirectory
./github-scaffold.sh preview <url>     # Preview structure
./github-scaffold.sh download <url>    # Download files
```

**Examples:**
```bash
# Clone specific subdirectory
./github-scaffold.sh clone https://github.com/pulumi/automation-api-examples/tree/main/nodejs

# Preview before downloading
./github-scaffold.sh preview https://github.com/vercel/next.js/tree/canary/examples/blog-starter
```

**Documentation:** [README-github-scaffold.md](./README-github-scaffold.md)
**Quick Start:** [QUICKSTART-github-scaffold.md](./QUICKSTART-github-scaffold.md)

---

## 📦 Installation

### Manual Installation

1. Clone this repository:
   ```bash
   git clone <repo-url> ~/.claude/plugins
   ```

2. Make scripts executable:
   ```bash
   chmod +x ~/.claude/plugins/*.sh
   ```

### Dependencies

**Git Commit Plugin:**
- `bash` (built-in)
- `git` (built-in)

**GitHub Scaffold Plugin:**
- `curl` (built-in)
- `jq` - Install: `sudo apt-get install jq`

---

## 🚀 Quick Start

### Git Commit Plugin

```bash
cd /path/to/your/repo

# Analyze your changes
~/.claude/plugins/git-commit.sh analyze

# Create organized commits
~/.claude/plugins/git-commit.sh commit

# Commit and push
~/.claude/plugins/git-commit.sh commit-push
```

### GitHub Scaffold Plugin

```bash
# Preview a repository structure
~/.claude/plugins/github-scaffold.sh preview https://github.com/owner/repo/tree/main/path

# Clone it
~/.claude/plugins/github-scaffold.sh clone https://github.com/owner/repo/tree/main/path

# Clone to specific location
~/.claude/plugins/github-scaffold.sh clone https://github.com/owner/repo my-project
```

---

## 📖 Documentation

Each plugin has detailed documentation:

- **Git Commit:** [README-git-commit.md](./README-git-commit.md)
- **GitHub Scaffold:** [README-github-scaffold.md](./README-github-scaffold.md)
- **GitHub Scaffold Quick Start:** [QUICKSTART-github-scaffold.md](./QUICKSTART-github-scaffold.md)

---

## 🛠️ Plugin Structure

```
claude-plugins/
├── README.md                           # This file
├── git-commit.json                     # Git commit plugin manifest
├── git-commit.sh                       # Git commit plugin script
├── README-git-commit.md                # Git commit documentation
├── github-scaffold.json                # GitHub scaffold plugin manifest
├── github-scaffold.sh                  # GitHub scaffold plugin script
├── README-github-scaffold.md           # GitHub scaffold documentation
└── QUICKSTART-github-scaffold.md       # GitHub scaffold quick start
```

---

## 💡 Use Cases

### Git Commit Plugin

**Perfect for:**
- Maintaining clean git history
- Following Conventional Commits specification
- Organizing commits by context (src, test, docs, ci)
- Creating professional commit messages
- Teams requiring standardized commit formats

**Example Workflow:**
```bash
# Make changes to multiple files
vim src/auth.js test/auth.test.js README.md

# Plugin automatically groups by context:
# - src (auth.js) → feat/fix commit
# - test (auth.test.js) → test commit
# - docs (README.md) → docs commit

./git-commit.sh commit
```

### GitHub Scaffold Plugin

**Perfect for:**
- Cloning monorepo subdirectories
- Getting examples from large repositories
- Scaffolding new projects from templates
- Downloading specific code samples
- Working with Terraform modules
- Getting documentation sections

**Example Workflow:**
```bash
# Find an example you like on GitHub
# e.g., https://github.com/vercel/next.js/tree/canary/examples/with-docker

# Preview it first
./github-scaffold.sh preview https://github.com/vercel/next.js/tree/canary/examples/with-docker

# Clone just that example
./github-scaffold.sh clone https://github.com/vercel/next.js/tree/canary/examples/with-docker my-app

cd my-app
npm install
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests
- Improve documentation

---

## 📝 License

MIT License - Feel free to use these plugins in your projects!

---

## 🎯 Future Plugins

Ideas for future plugins:
- **Project Init Plugin** - Scaffold new projects with templates
- **Code Review Plugin** - Automated code review helpers
- **Changelog Generator** - Generate changelogs from commits
- **Docker Helper** - Docker container management
- **Environment Manager** - Manage .env files across environments

---

## 📧 Support

For issues or questions:
- Open an issue in the repository
- Check the documentation in each plugin's README

---

**Version:** 1.0.0
**Author:** Claude Code
**Last Updated:** 2025-10-20
