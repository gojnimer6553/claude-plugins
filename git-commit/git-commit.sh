#!/bin/bash
set -euo pipefail

# Git Commit Plugin - Organized commits with conventional commit format
# Usage: git-commit.sh {commit|commit-push|analyze}

COMMAND="${1:-commit}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Conventional commit types
declare -A COMMIT_TYPES=(
    ["feat"]="A new feature"
    ["fix"]="A bug fix"
    ["docs"]="Documentation only changes"
    ["style"]="Changes that do not affect the meaning of the code (white-space, formatting, etc)"
    ["refactor"]="A code change that neither fixes a bug nor adds a feature"
    ["perf"]="A code change that improves performance"
    ["test"]="Adding missing tests or correcting existing tests"
    ["build"]="Changes that affect the build system or external dependencies"
    ["ci"]="Changes to CI configuration files and scripts"
    ["chore"]="Other changes that don't modify src or test files"
    ["revert"]="Reverts a previous commit"
)

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        print_error "Not a git repository"
        exit 1
    fi
}

# Get git status information
get_git_status() {
    git status --porcelain
}

# Analyze changes and group by context
analyze_changes() {
    local status_output="$1"

    declare -A file_groups

    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            continue
        fi

        local status="${line:0:2}"
        local file="${line:3}"

        # Determine context based on file path
        local context="other"

        if [[ "$file" =~ ^src/ ]]; then
            context="src"
        elif [[ "$file" =~ ^test/ ]] || [[ "$file" =~ \.test\. ]] || [[ "$file" =~ \.spec\. ]]; then
            context="test"
        elif [[ "$file" =~ ^docs?/ ]] || [[ "$file" =~ \.md$ ]]; then
            context="docs"
        elif [[ "$file" =~ ^\.github/ ]] || [[ "$file" =~ \.ya?ml$ ]]; then
            context="ci"
        elif [[ "$file" =~ package\.json ]] || [[ "$file" =~ go\.mod ]] || [[ "$file" =~ Cargo\.toml ]] || [[ "$file" =~ requirements\.txt ]]; then
            context="build"
        elif [[ "$file" =~ ^scripts?/ ]]; then
            context="chore"
        elif [[ "$file" =~ ^coder-templates/ ]]; then
            context="templates"
        elif [[ "$file" =~ main\.tf$ ]]; then
            context="terraform"
        fi

        if [[ -z "${file_groups[$context]:-}" ]]; then
            file_groups[$context]="$file"
        else
            file_groups[$context]="${file_groups[$context]}"$'\n'"$file"
        fi
    done <<< "$status_output"

    # Output groups
    for context in "${!file_groups[@]}"; do
        echo "CONTEXT:$context"
        echo "${file_groups[$context]}"
        echo "---"
    done
}

# Suggest commit type based on changes
suggest_commit_type() {
    local files="$1"
    local context="$2"

    # Check file content for clues
    local has_test=false
    local has_new_file=false
    local has_deletion=false

    while IFS= read -r file; do
        if git diff --cached "$file" | grep -q "^+.*test\|^+.*describe\|^+.*it("; then
            has_test=true
        fi

        if git diff --cached --diff-filter=A --name-only | grep -q "$file"; then
            has_new_file=true
        fi

        if git diff --cached --diff-filter=D --name-only | grep -q "$file"; then
            has_deletion=true
        fi
    done <<< "$files"

    # Suggest type based on context and content
    case "$context" in
        test)
            echo "test"
            ;;
        docs)
            echo "docs"
            ;;
        ci)
            echo "ci"
            ;;
        build)
            echo "build"
            ;;
        templates|terraform)
            if [[ "$has_new_file" == true ]]; then
                echo "feat"
            else
                echo "refactor"
            fi
            ;;
        src)
            if [[ "$has_new_file" == true ]]; then
                echo "feat"
            elif [[ "$has_deletion" == true ]]; then
                echo "refactor"
            else
                echo "fix"
            fi
            ;;
        *)
            echo "chore"
            ;;
    esac
}

# Create commit message
create_commit_message() {
    local type="$1"
    local scope="$2"
    local subject="$3"
    local body="${4:-}"

    local message="$type"

    if [[ -n "$scope" ]]; then
        message="$message($scope)"
    fi

    message="$message: $subject"

    if [[ -n "$body" ]]; then
        message="$message"$'\n\n'"$body"
    fi

    echo "$message"
}

# Interactive commit type selection
select_commit_type() {
    local suggested="$1"

    print_info "Suggested type: ${GREEN}$suggested${NC}"
    echo ""
    echo "Available commit types:"
    echo ""

    local i=1
    local types=()
    for type in "${!COMMIT_TYPES[@]}"; do
        types+=("$type")
    done

    # Sort types
    IFS=$'\n' sorted_types=($(sort <<<"${types[*]}"))
    unset IFS

    for type in "${sorted_types[@]}"; do
        local marker=" "
        if [[ "$type" == "$suggested" ]]; then
            marker="${GREEN}►${NC}"
        fi
        printf "%s %2d) ${CYAN}%-10s${NC} %s\n" "$marker" "$i" "$type" "${COMMIT_TYPES[$type]}"
        ((i++))
    done

    echo ""
    read -p "Select commit type [1-${#sorted_types[@]}] or press Enter for suggested ($suggested): " choice

    if [[ -z "$choice" ]]; then
        echo "$suggested"
    else
        echo "${sorted_types[$((choice-1))]}"
    fi
}

# Analyze command
cmd_analyze() {
    print_header "Git Changes Analysis"

    local status_output
    status_output=$(get_git_status)

    if [[ -z "$status_output" ]]; then
        print_warning "No changes detected"
        exit 0
    fi

    print_info "Analyzing changes and grouping by context...\n"

    local groups
    groups=$(analyze_changes "$status_output")

    echo "$groups" | while IFS= read -r line; do
        if [[ "$line" =~ ^CONTEXT: ]]; then
            local context="${line#CONTEXT:}"
            local files=""

            # Read files for this context
            while IFS= read -r file_line; do
                if [[ "$file_line" == "---" ]]; then
                    break
                fi
                if [[ -n "$file_line" ]]; then
                    files="$files"$'\n'"$file_line"
                fi
            done

            local suggested_type
            suggested_type=$(suggest_commit_type "$files" "$context")

            echo -e "\n${CYAN}Context: $context${NC}"
            echo -e "Suggested type: ${GREEN}$suggested_type${NC}"
            echo "Files:"
            echo "$files" | while IFS= read -r f; do
                if [[ -n "$f" ]]; then
                    echo "  - $f"
                fi
            done
        fi
    done
}

# Commit command
cmd_commit() {
    local should_push="${1:-false}"

    print_header "Git Commit Helper"

    # Check for staged changes
    if ! git diff --cached --quiet; then
        print_info "Found staged changes"
    else
        print_warning "No staged changes found. Staging all changes..."
        git add -A
    fi

    local status_output
    status_output=$(get_git_status)

    if [[ -z "$status_output" ]]; then
        print_warning "No changes to commit"
        exit 0
    fi

    # Analyze and group changes
    print_info "Analyzing changes...\n"
    local groups
    groups=$(analyze_changes "$status_output")

    local contexts=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^CONTEXT: ]]; then
            contexts+=("${line#CONTEXT:}")
        fi
    done <<< "$groups"

    if [[ ${#contexts[@]} -eq 0 ]]; then
        print_error "No changes detected"
        exit 1
    fi

    print_success "Found ${#contexts[@]} context group(s): ${contexts[*]}\n"

    # Process each context
    for context in "${contexts[@]}"; do
        print_header "Context: $context"

        # Get files for this context
        local files=""
        local in_context=false
        while IFS= read -r line; do
            if [[ "$line" == "CONTEXT:$context" ]]; then
                in_context=true
                continue
            elif [[ "$line" == "---" ]]; then
                in_context=false
                break
            elif [[ "$in_context" == true ]] && [[ -n "$line" ]]; then
                files="$files"$'\n'"$line"
            fi
        done <<< "$groups"

        echo "Files in this context:"
        echo "$files" | while IFS= read -r f; do
            if [[ -n "$f" ]]; then
                echo "  - $f"
            fi
        done
        echo ""

        # Suggest commit type
        local suggested_type
        suggested_type=$(suggest_commit_type "$files" "$context")

        # Interactive type selection
        local commit_type
        commit_type=$(select_commit_type "$suggested_type")

        # Get scope
        read -p "Scope (optional, e.g., 'incus', 'api', 'auth'): " scope

        # Get subject
        read -p "Commit subject (short description): " subject

        while [[ -z "$subject" ]]; do
            print_error "Subject cannot be empty"
            read -p "Commit subject (short description): " subject
        done

        # Get body (optional)
        echo "Commit body (optional, press Enter to skip, Ctrl+D when done):"
        body=$(cat)

        # Create commit message
        local commit_message
        commit_message=$(create_commit_message "$commit_type" "$scope" "$subject" "$body")

        echo ""
        print_info "Commit message preview:"
        echo -e "${YELLOW}┌─────────────────────────────────────────${NC}"
        echo "$commit_message" | while IFS= read -r line; do
            echo -e "${YELLOW}│${NC} $line"
        done
        echo -e "${YELLOW}└─────────────────────────────────────────${NC}"
        echo ""

        read -p "Commit these changes? [Y/n]: " confirm
        confirm=${confirm:-Y}

        if [[ "$confirm" =~ ^[Yy] ]]; then
            # Stage files for this context
            echo "$files" | while IFS= read -r f; do
                if [[ -n "$f" ]]; then
                    git add "$f"
                fi
            done

            # Commit
            git commit -m "$commit_message"
            print_success "Committed successfully!"
        else
            print_warning "Skipped commit for context: $context"
        fi

        echo ""
    done

    # Push if requested
    if [[ "$should_push" == "true" ]]; then
        print_header "Push to Remote"

        read -p "Push to remote? [Y/n]: " confirm_push
        confirm_push=${confirm_push:-Y}

        if [[ "$confirm_push" =~ ^[Yy] ]]; then
            local current_branch
            current_branch=$(git branch --show-current)

            print_info "Pushing to origin/$current_branch..."
            git push origin "$current_branch"
            print_success "Pushed successfully!"
        else
            print_warning "Push cancelled"
        fi
    fi
}

# Main
main() {
    check_git_repo

    case "$COMMAND" in
        analyze)
            cmd_analyze
            ;;
        commit)
            cmd_commit false
            ;;
        commit-push)
            cmd_commit true
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            echo "Usage: $0 {analyze|commit|commit-push}"
            exit 1
            ;;
    esac
}

main
