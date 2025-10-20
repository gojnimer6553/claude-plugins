# Claude Code Plugins

A collection of useful plugins for Claude Code to enhance your development workflow.

## 🔌 Available Plugins

### 1. **Git Commit Plugin** (`git-commit/`)
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
~/.claude/plugins/git-commit/git-commit.sh commit
~/.claude/plugins/git-commit/git-commit.sh commit-push
~/.claude/plugins/git-commit/git-commit.sh analyze
```

**Documentation:** [git-commit/README.md](./git-commit/README.md)

---

### 2. **GitHub Scaffold Plugin** (`github-scaffold/`)
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
~/.claude/plugins/github-scaffold/github-scaffold.sh clone <url>
~/.claude/plugins/github-scaffold/github-scaffold.sh preview <url>
~/.claude/plugins/github-scaffold/github-scaffold.sh download <url>
```

**Examples:**
```bash
# Clone specific subdirectory
~/.claude/plugins/github-scaffold/github-scaffold.sh clone https://github.com/pulumi/automation-api-examples/tree/main/nodejs

# Preview before downloading
~/.claude/plugins/github-scaffold/github-scaffold.sh preview https://github.com/vercel/next.js/tree/canary/examples/blog-starter
```

**Documentation:** [github-scaffold/README.md](./github-scaffold/README.md)
**Quick Start:** [github-scaffold/QUICKSTART.md](./github-scaffold/QUICKSTART.md)

---

## 📦 Installation

### Clone to Claude Plugins Directory

```bash
# Clone this repository to your Claude plugins directory
cd ~/.claude/plugins
git clone https://github.com/gojnimer6553/claude-plugins .

# Make scripts executable
chmod +x git-commit/git-commit.sh
chmod +x github-scaffold/github-scaffold.sh
```

### Or Install Individual Plugins

```bash
# Install git-commit plugin
cd ~/.claude/plugins
git clone https://github.com/gojnimer6553/claude-plugins
cp -r claude-plugins/git-commit .

# Install github-scaffold plugin
cp -r claude-plugins/github-scaffold .
chmod +x */*.sh
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
~/.claude/plugins/git-commit/git-commit.sh analyze

# Create organized commits
~/.claude/plugins/git-commit/git-commit.sh commit

# Commit and push
~/.claude/plugins/git-commit/git-commit.sh commit-push
```

### GitHub Scaffold Plugin

```bash
# Preview a repository structure
~/.claude/plugins/github-scaffold/github-scaffold.sh preview https://github.com/owner/repo/tree/main/path

# Clone it
~/.claude/plugins/github-scaffold/github-scaffold.sh clone https://github.com/owner/repo/tree/main/path

# Clone to specific location
~/.claude/plugins/github-scaffold/github-scaffold.sh clone https://github.com/owner/repo my-project
```

---

## 🛠️ Plugin Structure

Each plugin follows the Claude Code plugin format:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── plugin-name.sh           # Main script
└── README.md               # Documentation
```

### Current Structure

```
claude-plugins/
├── README.md
├── git-commit/
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── git-commit.sh
│   └── README.md
└── github-scaffold/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── github-scaffold.sh
    ├── README.md
    └── QUICKSTART.md
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

~/.claude/plugins/git-commit/git-commit.sh commit
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
~/.claude/plugins/github-scaffold/github-scaffold.sh preview https://github.com/vercel/next.js/tree/canary/examples/with-docker

# Clone just that example
~/.claude/plugins/github-scaffold/github-scaffold.sh clone https://github.com/vercel/next.js/tree/canary/examples/with-docker my-app

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
- Open an issue in the [GitHub repository](https://github.com/gojnimer6553/claude-plugins)
- Check the documentation in each plugin's README

---

**Version:** 1.0.0
**Author:** Claude Code
**Last Updated:** 2025-10-20
