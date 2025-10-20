# GitHub Scaffold Plugin - Quick Start

## 🚀 Quick Commands

### Preview a Repository
```bash
~/.claude/plugins/github-scaffold.sh preview <github-url>
```

### Clone a Repository
```bash
~/.claude/plugins/github-scaffold.sh clone <github-url>
```

### Clone to Specific Location
```bash
~/.claude/plugins/github-scaffold.sh clone <github-url> my-folder
```

## 📝 Common Examples

### Example from Your Request
```bash
# Preview the Pulumi Node.js examples
~/.claude/plugins/github-scaffold.sh preview https://github.com/pulumi/automation-api-examples/tree/main/nodejs

# Clone it
~/.claude/plugins/github-scaffold.sh clone https://github.com/pulumi/automation-api-examples/tree/main/nodejs
```

### Clone Subdirectory Only
```bash
# Clone just the 'src' folder from a repo
~/.claude/plugins/github-scaffold.sh clone https://github.com/owner/repo/tree/main/src
```

### Clone from Different Branch
```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/owner/repo/tree/develop
```

### Clone Terraform Examples
```bash
~/.claude/plugins/github-scaffold.sh clone https://github.com/terraform-aws-modules/terraform-aws-vpc/tree/master/examples
```

## ⚙️ Setup GitHub Token (Optional)

For higher rate limits (5000 vs 60 requests/hour):

```bash
# Create token at: https://github.com/settings/tokens
export GITHUB_TOKEN="your_token_here"

# Add to ~/.bashrc for persistence
echo 'export GITHUB_TOKEN="your_token_here"' >> ~/.bashrc
```

## 🎯 URL Format Support

All these work:
```
https://github.com/owner/repo
https://github.com/owner/repo/tree/branch
https://github.com/owner/repo/tree/branch/path/to/dir
https://github.com/owner/repo/blob/branch/path/to/file
```

## ✨ Features

- ✅ Clone entire repos
- ✅ Clone subdirectories
- ✅ Choose specific branches
- ✅ Preview before downloading
- ✅ Beautiful tree output
- ✅ No git history (smaller downloads)

## 📚 Full Documentation

See: `~/.claude/plugins/README-github-scaffold.md`
