#!/bin/bash
set -euo pipefail

# GitHub Scaffold Plugin - Clone and scaffold from GitHub repos with subdirectory support
# Usage: github-scaffold.sh {clone|preview|download} <github-url> [destination]

COMMAND="${1:-}"
GITHUB_URL="${2:-}"
DESTINATION="${3:-.}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

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

# Parse GitHub URL
# Supports:
# - https://github.com/owner/repo
# - https://github.com/owner/repo/tree/branch/path/to/dir
# - https://github.com/owner/repo/blob/branch/path/to/file
parse_github_url() {
    local url="$1"

    # Remove trailing slash
    url="${url%/}"

    # Extract parts
    if [[ "$url" =~ ^https?://github\.com/([^/]+)/([^/]+)(/tree/([^/]+)(/(.+))?)?$ ]]; then
        OWNER="${BASH_REMATCH[1]}"
        REPO="${BASH_REMATCH[2]}"
        BRANCH="${BASH_REMATCH[4]:-main}"
        SUBPATH="${BASH_REMATCH[6]:-}"

        # Clean up repo name (remove .git)
        REPO="${REPO%.git}"

        return 0
    elif [[ "$url" =~ ^https?://github\.com/([^/]+)/([^/]+)(/blob/([^/]+)/(.+))?$ ]]; then
        OWNER="${BASH_REMATCH[1]}"
        REPO="${BASH_REMATCH[2]}"
        BRANCH="${BASH_REMATCH[4]:-main}"
        SUBPATH="${BASH_REMATCH[5]:-}"

        # Clean up repo name
        REPO="${REPO%.git}"

        return 0
    else
        print_error "Invalid GitHub URL format"
        print_info "Supported formats:"
        echo "  - https://github.com/owner/repo"
        echo "  - https://github.com/owner/repo/tree/branch"
        echo "  - https://github.com/owner/repo/tree/branch/path/to/dir"
        echo "  - https://github.com/owner/repo/blob/branch/path/to/file"
        return 1
    fi
}

# Get GitHub API URL
get_api_url() {
    local owner="$1"
    local repo="$2"
    local branch="$3"
    local path="${4:-}"

    if [[ -n "$path" ]]; then
        echo "https://api.github.com/repos/$owner/$repo/contents/$path?ref=$branch"
    else
        echo "https://api.github.com/repos/$owner/$repo/contents?ref=$branch"
    fi
}

# Fetch directory contents from GitHub API
fetch_contents() {
    local api_url="$1"
    local github_token="${GITHUB_TOKEN:-}"

    local auth_header=""
    if [[ -n "$github_token" ]]; then
        auth_header="-H \"Authorization: token $github_token\""
    fi

    local response
    if [[ -n "$auth_header" ]]; then
        response=$(curl -s -H "Authorization: token $github_token" "$api_url")
    else
        response=$(curl -s "$api_url")
    fi

    # Check for API errors
    if echo "$response" | jq -e '.message' >/dev/null 2>&1; then
        local error_msg
        error_msg=$(echo "$response" | jq -r '.message')
        print_error "GitHub API error: $error_msg"

        if [[ "$error_msg" == *"rate limit"* ]]; then
            print_warning "API rate limit exceeded. Set GITHUB_TOKEN environment variable for higher limits."
        fi
        return 1
    fi

    echo "$response"
}

# Display tree structure
display_tree() {
    local path="$1"
    local prefix="${2:-}"
    local is_last="${3:-true}"

    local api_url
    api_url=$(get_api_url "$OWNER" "$REPO" "$BRANCH" "$path")

    local contents
    contents=$(fetch_contents "$api_url") || return 1

    # Check if it's a single file
    if echo "$contents" | jq -e '.type == "file"' >/dev/null 2>&1; then
        local name
        name=$(echo "$contents" | jq -r '.name')
        if [[ "$is_last" == "true" ]]; then
            echo "${prefix}└── $name"
        else
            echo "${prefix}├── $name"
        fi
        return 0
    fi

    # Get items
    local items
    items=$(echo "$contents" | jq -c '.[]')

    if [[ -z "$items" ]]; then
        return 0
    fi

    local total_items
    total_items=$(echo "$items" | wc -l)
    local current=0

    while IFS= read -r item; do
        ((current++))

        local name type
        name=$(echo "$item" | jq -r '.name')
        type=$(echo "$item" | jq -r '.type')

        local item_is_last="false"
        [[ $current -eq $total_items ]] && item_is_last="true"

        local connector="├── "
        local new_prefix="${prefix}│   "

        if [[ "$item_is_last" == "true" ]]; then
            connector="└── "
            new_prefix="${prefix}    "
        fi

        if [[ "$type" == "dir" ]]; then
            echo "${prefix}${connector}${CYAN}${name}/${NC}"

            # Recursively display subdirectories
            local subpath
            if [[ -n "$path" ]]; then
                subpath="$path/$name"
            else
                subpath="$name"
            fi

            display_tree "$subpath" "$new_prefix" "$item_is_last"
        else
            echo "${prefix}${connector}$name"
        fi
    done <<< "$items"
}

# Download file
download_file() {
    local url="$1"
    local destination="$2"

    local dir
    dir=$(dirname "$destination")
    mkdir -p "$dir"

    if curl -sL "$url" -o "$destination"; then
        return 0
    else
        return 1
    fi
}

# Download directory recursively
download_directory() {
    local path="$1"
    local dest_base="$2"
    local depth="${3:-0}"

    local api_url
    api_url=$(get_api_url "$OWNER" "$REPO" "$BRANCH" "$path")

    local contents
    contents=$(fetch_contents "$api_url") || return 1

    # Check if it's a single file
    if echo "$contents" | jq -e '.type == "file"' >/dev/null 2>&1; then
        local download_url name
        download_url=$(echo "$contents" | jq -r '.download_url')
        name=$(echo "$contents" | jq -r '.name')

        local dest_file="$dest_base/$name"
        print_info "Downloading: $name"

        if download_file "$download_url" "$dest_file"; then
            print_success "Downloaded: $dest_file"
        else
            print_error "Failed to download: $name"
            return 1
        fi
        return 0
    fi

    # Process directory items
    local items
    items=$(echo "$contents" | jq -c '.[]')

    if [[ -z "$items" ]]; then
        return 0
    fi

    while IFS= read -r item; do
        local name type download_url
        name=$(echo "$item" | jq -r '.name')
        type=$(echo "$item" | jq -r '.type')
        download_url=$(echo "$item" | jq -r '.download_url // empty')

        if [[ "$type" == "file" ]]; then
            local dest_file="$dest_base/$name"

            local indent=""
            for ((i=0; i<depth; i++)); do
                indent="  $indent"
            done

            print_info "${indent}Downloading: $name"

            if download_file "$download_url" "$dest_file"; then
                print_success "${indent}✓ $name"
            else
                print_error "${indent}✗ Failed: $name"
            fi
        elif [[ "$type" == "dir" ]]; then
            local subpath
            if [[ -n "$path" ]]; then
                subpath="$path/$name"
            else
                subpath="$name"
            fi

            local subdest="$dest_base/$name"
            mkdir -p "$subdest"

            print_info "Entering directory: ${CYAN}$name/${NC}"
            download_directory "$subpath" "$subdest" $((depth + 1))
        fi
    done <<< "$items"
}

# Preview command
cmd_preview() {
    print_header "GitHub Repository Preview"

    if [[ -z "$GITHUB_URL" ]]; then
        print_error "GitHub URL is required"
        echo "Usage: $0 preview <github-url>"
        exit 1
    fi

    if ! parse_github_url "$GITHUB_URL"; then
        exit 1
    fi

    print_info "Repository: ${GREEN}$OWNER/$REPO${NC}"
    print_info "Branch: ${YELLOW}$BRANCH${NC}"
    if [[ -n "$SUBPATH" ]]; then
        print_info "Path: ${CYAN}$SUBPATH${NC}"
    fi
    echo ""

    print_header "Directory Structure"

    if [[ -n "$SUBPATH" ]]; then
        echo "${CYAN}$SUBPATH/${NC}"
        display_tree "$SUBPATH" ""
    else
        echo "${CYAN}$REPO/${NC}"
        display_tree "" ""
    fi
}

# Clone command
cmd_clone() {
    print_header "GitHub Scaffold Clone"

    if [[ -z "$GITHUB_URL" ]]; then
        print_error "GitHub URL is required"
        echo "Usage: $0 clone <github-url> [destination]"
        exit 1
    fi

    if ! parse_github_url "$GITHUB_URL"; then
        exit 1
    fi

    print_info "Repository: ${GREEN}$OWNER/$REPO${NC}"
    print_info "Branch: ${YELLOW}$BRANCH${NC}"
    if [[ -n "$SUBPATH" ]]; then
        print_info "Path: ${CYAN}$SUBPATH${NC}"
    fi
    print_info "Destination: ${MAGENTA}$DESTINATION${NC}"
    echo ""

    # Determine destination directory
    local dest_dir="$DESTINATION"
    if [[ "$dest_dir" == "." ]]; then
        if [[ -n "$SUBPATH" ]]; then
            dest_dir=$(basename "$SUBPATH")
        else
            dest_dir="$REPO"
        fi
    fi

    # Create destination directory
    if [[ -d "$dest_dir" ]]; then
        read -p "Directory '$dest_dir' already exists. Overwrite? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_warning "Clone cancelled"
            exit 0
        fi
    fi

    mkdir -p "$dest_dir"

    print_header "Downloading Files"

    # Download the repository/subdirectory
    if download_directory "$SUBPATH" "$dest_dir"; then
        echo ""
        print_success "Successfully scaffolded to: ${MAGENTA}$dest_dir${NC}"

        # Show tree of downloaded structure
        echo ""
        print_header "Downloaded Structure"
        if command -v tree >/dev/null 2>&1; then
            tree -L 3 "$dest_dir"
        else
            find "$dest_dir" -type f | head -20
            local total_files
            total_files=$(find "$dest_dir" -type f | wc -l)
            if [[ $total_files -gt 20 ]]; then
                print_info "... and $((total_files - 20)) more files"
            fi
        fi
    else
        print_error "Failed to download repository"
        exit 1
    fi
}

# Download command (selective download)
cmd_download() {
    print_header "GitHub Selective Download"

    if [[ -z "$GITHUB_URL" ]]; then
        print_error "GitHub URL is required"
        echo "Usage: $0 download <github-url> [destination]"
        exit 1
    fi

    if ! parse_github_url "$GITHUB_URL"; then
        exit 1
    fi

    print_info "Repository: ${GREEN}$OWNER/$REPO${NC}"
    print_info "Branch: ${YELLOW}$BRANCH${NC}"
    if [[ -n "$SUBPATH" ]]; then
        print_info "Path: ${CYAN}$SUBPATH${NC}"
    fi
    echo ""

    # Determine destination
    local dest_dir="$DESTINATION"
    if [[ "$dest_dir" == "." ]]; then
        dest_dir="."
    fi

    mkdir -p "$dest_dir"

    print_header "Downloading"

    if download_directory "$SUBPATH" "$dest_dir"; then
        echo ""
        print_success "Successfully downloaded to: ${MAGENTA}$dest_dir${NC}"
    else
        print_error "Failed to download"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    local missing_deps=()

    if ! command -v curl >/dev/null 2>&1; then
        missing_deps+=("curl")
    fi

    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install: ${missing_deps[*]}"
        exit 1
    fi
}

# Show usage
show_usage() {
    cat << EOF
GitHub Scaffold Plugin

Usage:
  $0 clone <github-url> [destination]     - Clone repository or subdirectory
  $0 preview <github-url>                 - Preview repository structure
  $0 download <github-url> [destination]  - Download specific path

Examples:
  # Clone entire repository
  $0 clone https://github.com/owner/repo

  # Clone specific subdirectory
  $0 clone https://github.com/pulumi/automation-api-examples/tree/main/nodejs

  # Clone from specific branch
  $0 clone https://github.com/owner/repo/tree/develop

  # Preview structure
  $0 preview https://github.com/owner/repo/tree/main/src

  # Download to specific location
  $0 clone https://github.com/owner/repo my-project

Environment Variables:
  GITHUB_TOKEN  - GitHub personal access token (for higher API rate limits)

EOF
}

# Main
main() {
    check_dependencies

    case "$COMMAND" in
        clone)
            cmd_clone
            ;;
        preview)
            cmd_preview
            ;;
        download)
            cmd_download
            ;;
        help|--help|-h)
            show_usage
            ;;
        "")
            print_error "Command is required"
            echo ""
            show_usage
            exit 1
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main
