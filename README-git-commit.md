# Git Commit Plugin

Organized git commits with conventional commit format and intelligent context-based grouping.

## Features

- 🎯 **Conventional Commits**: Follows the [Conventional Commits](https://www.conventionalcommits.org/) specification
- 📁 **Context Grouping**: Automatically groups changes by context (src, test, docs, ci, build, etc.)
- 🤖 **Smart Suggestions**: Suggests appropriate commit types based on file changes
- 🎨 **Interactive**: User-friendly interactive prompts for commit creation
- 🚀 **Optional Push**: Can automatically push commits when requested
- ✨ **Clean Messages**: No extra footers or signatures - just clean, professional commits

## Installation

The plugin is already installed at `~/.claude/plugins/git-commit.sh`

## Usage

### Analyze Changes

Analyze your current changes and see suggested commit structure:

```bash
~/.claude/plugins/git-commit.sh analyze
```

### Create Commits

Create organized commits interactively:

```bash
~/.claude/plugins/git-commit.sh commit
```

### Commit and Push

Create commits and optionally push to remote:

```bash
~/.claude/plugins/git-commit.sh commit-push
```

## Commit Message Format

The plugin follows the Conventional Commits format:

```
<type>(<scope>): <subject>

<body>
```

### Commit Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Code style changes (formatting, missing semicolons, etc)
- **refactor**: Code changes that neither fix bugs nor add features
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **build**: Changes to build system or dependencies
- **ci**: Changes to CI configuration
- **chore**: Other changes (tooling, etc)
- **revert**: Revert a previous commit

### Examples

```
feat(incus): add file block for token management

Replaced null_resource with incus_instance file block
for cleaner token updates via Incus API.
```

```
fix(auth): resolve token refresh race condition

Added proper dependency handling to ensure token
file is updated before agent restart.
```

```
docs: update README with installation instructions
```

## Context Detection

The plugin automatically detects file contexts:

| Context | File Patterns | Suggested Type |
|---------|--------------|----------------|
| **src** | `src/**` | feat/fix |
| **test** | `test/**`, `*.test.*`, `*.spec.*` | test |
| **docs** | `docs/**`, `*.md` | docs |
| **ci** | `.github/**`, `*.yml`, `*.yaml` | ci |
| **build** | `package.json`, `go.mod`, `Cargo.toml` | build |
| **templates** | `coder-templates/**` | feat/refactor |
| **terraform** | `*.tf` | feat/refactor |

## Interactive Workflow

1. **Stage changes** (automatic if nothing staged)
2. **Group by context** (automatic analysis)
3. **For each context**:
   - View affected files
   - Select commit type (with smart suggestions)
   - Enter scope (optional)
   - Enter subject line
   - Enter body (optional)
   - Preview commit message
   - Confirm commit
4. **Optionally push** to remote

## Tips

### Best Practices

- Use **feat** for new features or capabilities
- Use **fix** for bug fixes
- Use **refactor** for code changes without behavior changes
- Keep subject lines under 50 characters
- Use the body to explain "why" not "what"

### Scope Examples

- `feat(incus)`: Feature for Incus templates
- `fix(api)`: Bug fix in API layer
- `docs(readme)`: README documentation update
- `ci(github)`: GitHub Actions changes

### Multi-Context Commits

If you have changes across multiple contexts (e.g., src + tests), the plugin will:
1. Detect both contexts
2. Create separate commits for each
3. Group related files automatically

This keeps your git history clean and organized!

## Troubleshooting

### No changes detected

Make sure you have modified files:
```bash
git status
```

### Script not executable

```bash
chmod +x ~/.claude/plugins/git-commit.sh
```

### Not in a git repository

```bash
cd /path/to/your/git/repo
```

## Examples

### Single Context Commit

```bash
$ ~/.claude/plugins/git-commit.sh commit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Git Commit Helper
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ Found staged changes
ℹ Analyzing changes...

✓ Found 1 context group(s): terraform

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Context: terraform
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Files in this context:
  - coder-templates/incus/main.tf

ℹ Suggested type: refactor

Available commit types:
  1) build      Changes that affect the build system or external dependencies
  2) chore      Other changes that don't modify src or test files
  3) ci         Changes to CI configuration files and scripts
  4) docs       Documentation only changes
► 5) feat       A new feature
  6) fix        A bug fix
  7) perf       A code change that improves performance
  8) refactor   A code change that neither fixes a bug nor adds a feature
  9) revert     Reverts a previous commit
  10) style     Changes that do not affect the meaning of the code
  11) test      Adding missing tests or correcting existing tests

Select commit type [1-11] or press Enter for suggested (refactor):
Scope (optional, e.g., 'incus', 'api', 'auth'): incus
Commit subject (short description): replace null_resource with file block
Commit body (optional, press Enter to skip, Ctrl+D when done):
Use Incus API for token updates instead of local-exec

ℹ Commit message preview:
┌─────────────────────────────────────────
│ refactor(incus): replace null_resource with file block
│
│ Use Incus API for token updates instead of local-exec
└─────────────────────────────────────────

Commit these changes? [Y/n]: y
✓ Committed successfully!
```

## Integration with Claude Code

You can call this plugin from Claude Code workflows or use it standalone in your terminal.

---

**Version**: 1.0.0
**Author**: Claude Code
**License**: MIT
