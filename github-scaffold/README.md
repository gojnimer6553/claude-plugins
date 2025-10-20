# GitHub Scaffold Plugin

Easily clone and scaffold projects from GitHub repositories with full support for subdirectories, specific branches, and selective file downloads.

## Features

- 🌲 **Subdirectory Support**: Clone specific folders from repositories
- 🌿 **Branch Selection**: Work with any branch (main, develop, feature branches)
- 👁️ **Preview Mode**: View repository structure before downloading
- 📦 **Selective Download**: Download only what you need
- 🎨 **Beautiful Output**: Color-coded, tree-structured display
- ⚡ **GitHub API**: Uses GitHub API for reliable, efficient downloads
- 🔐 **Token Support**: Optional GitHub token for higher rate limits

## Installation

The plugin is installed at `~/.claude/plugins/github-scaffold.sh`

### Dependencies

Required:
- `curl` - HTTP client
- `jq` - JSON processor

Install on Debian/Ubuntu:
```bash
sudo apt-get install curl jq
```

## Usage

### Clone Entire Repository

```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/owner/repo
```

### Clone Subdirectory

This is perfect for monorepos or when you only need a specific part:

```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/pulumi/automation-api-examples/tree/main/nodejs
```

### Clone from Specific Branch

```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/owner/repo/tree/develop
```

### Preview Repository Structure

See what's in a repository before downloading:

```bash
~/.claude/plugins/github-scaffold.sh preview https://github.com/owner/repo/tree/main/src
```

### Download to Specific Location

```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/owner/repo my-project
```

## Supported URL Formats

The plugin intelligently parses various GitHub URL formats:

### Standard Repository
```
https://github.com/owner/repo
```

### Specific Branch
```
https://github.com/owner/repo/tree/branch-name
```

### Subdirectory
```
https://github.com/owner/repo/tree/branch/path/to/directory
```

### Single File
```
https://github.com/owner/repo/blob/branch/path/to/file.js
```

## Commands

### `clone`

Clone a repository or subdirectory to your local machine.

```bash
~/.claude/plugins/github-scaffold.sh clone <github-url> [destination]
```

**Arguments:**
- `github-url` (required): GitHub repository URL
- `destination` (optional): Target directory (defaults to repo/folder name)

**Examples:**
```bash
# Clone to auto-generated folder name
~/.claude/plugins/github-scaffold.sh clone https://github.com/pulumi/automation-api-examples/tree/main/nodejs

# Clone to specific directory
~/.claude/plugins/github-scaffold.sh clone https://github.com/owner/repo my-app
```

### `preview`

Preview the directory structure without downloading.

```bash
~/.claude/plugins/github-scaffold.sh preview <github-url>
```

**Example:**
```bash
~/.claude/plugins/github-scaffold.sh preview https://github.com/pulumi/automation-api-examples/tree/main/nodejs
```

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Directory Structure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

nodejs/
├── package.json
├── index.js
├── README.md
└── src/
    ├── config.js
    └── utils.js
```

### `download`

Download files to a specific location (alias for clone with explicit destination).

```bash
~/.claude/plugins/github-scaffold.sh download <github-url> [destination]
```

## Real-World Examples

### Example 1: Clone Pulumi Node.js Examples

```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/pulumi/automation-api-examples/tree/main/nodejs
```

Creates a `nodejs/` directory with:
- All Node.js example files
- Package.json and dependencies
- Example code and README

### Example 2: Clone Terraform Module

```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples/simple-vpc
```

### Example 3: Preview Before Downloading

```bash
# First, preview the structure
~/.claude/plugins/github-scaffold.sh preview https://github.com/vercel/next.js/tree/canary/examples/blog-starter

# If it looks good, clone it
~/.claude/plugins/github-scaffold.sh clone https://github.com/vercel/next.js/tree/canary/examples/blog-starter my-blog
```

### Example 4: Clone from Specific Branch

```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/facebook/react/tree/experimental/packages/react
```

## GitHub API Rate Limits

### Anonymous Access
- **60 requests per hour**
- Sufficient for most use cases

### With GitHub Token
- **5,000 requests per hour**
- Recommended for heavy usage

### Setting Up GitHub Token

1. **Create a token**: [github.com/settings/tokens](https://github.com/settings/tokens)
2. **Set environment variable**:
   ```bash
   export GITHUB_TOKEN="your_token_here"
   ```
3. **Make it permanent** (add to `~/.bashrc` or `~/.profile`):
   ```bash
   echo 'export GITHUB_TOKEN="your_token_here"' >> ~/.bashrc
   ```

## Advanced Usage

### Clone Multiple Subdirectories

```bash
# Clone different examples
~/.claude/plugins/github-scaffold.sh clone https://github.com/pulumi/automation-api-examples/tree/main/nodejs nodejs-example
~/.claude/plugins/github-scaffold.sh clone https://github.com/pulumi/automation-api-examples/tree/main/python python-example
~/.claude/plugins/github-scaffold.sh clone https://github.com/pulumi/automation-api-examples/tree/main/go go-example
```

### Preview Large Repositories

```bash
# Check structure before committing to download
~/.claude/plugins/github-scaffold.sh preview https://github.com/kubernetes/kubernetes/tree/master/examples
```

### Download Specific Documentation

```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/microsoft/TypeScript/tree/main/doc ./typescript-docs
```

## Output Examples

### Clone Command Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  GitHub Scaffold Clone
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ Repository: pulumi/automation-api-examples
ℹ Branch: main
ℹ Path: nodejs
ℹ Destination: nodejs

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Downloading Files
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ Downloading: package.json
✓ ✓ package.json
ℹ Downloading: index.js
✓ ✓ index.js
ℹ Entering directory: src/
  ℹ Downloading: config.js
  ✓ ✓ config.js

✓ Successfully scaffolded to: nodejs
```

### Preview Command Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  GitHub Repository Preview
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ Repository: pulumi/automation-api-examples
ℹ Branch: main
ℹ Path: nodejs

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Directory Structure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

nodejs/
├── package.json
├── index.js
├── README.md
└── src/
    ├── config.js
    ├── utils.js
    └── handlers/
        ├── create.js
        └── update.js
```

## Troubleshooting

### Rate Limit Exceeded

**Error**: `GitHub API error: API rate limit exceeded`

**Solution**: Set up a GitHub token (see above)

### Missing Dependencies

**Error**: `Missing required dependencies: jq curl`

**Solution**:
```bash
sudo apt-get install jq curl
```

### Invalid URL Format

**Error**: `Invalid GitHub URL format`

**Solution**: Make sure your URL follows one of these patterns:
- `https://github.com/owner/repo`
- `https://github.com/owner/repo/tree/branch`
- `https://github.com/owner/repo/tree/branch/path`

### Directory Already Exists

The plugin will ask for confirmation before overwriting:
```
Directory 'nodejs' already exists. Overwrite? [y/N]:
```

## Comparison with Git Clone

| Feature | `git clone` | `github-scaffold` |
|---------|-------------|-------------------|
| Clone entire repo | ✅ | ✅ |
| Clone subdirectory | ❌ | ✅ |
| Clone specific files | ❌ | ✅ |
| Includes .git history | ✅ | ❌ |
| Smaller download size | ❌ | ✅ |
| Preview before download | ❌ | ✅ |
| No git required | ❌ | ✅ |

## Use Cases

### 1. **Monorepo Examples**
Clone specific examples from large repositories:
```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/vercel/next.js/tree/canary/examples/with-docker
```

### 2. **Terraform Modules**
Get specific module examples:
```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples
```

### 3. **Documentation**
Download specific docs sections:
```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/kubernetes/website/tree/main/content/en/docs
```

### 4. **Code Templates**
Scaffold new projects from templates:
```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/coder/enterprise-helm/tree/main/templates my-app-templates
```

---

**Version**: 1.0.0
**Author**: Claude Code
**License**: MIT
