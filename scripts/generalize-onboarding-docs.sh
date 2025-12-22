#!/usr/bin/env bash

# Script to generalize onboarding documentation
# Replaces hardcoded references with placeholders

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Generalizing onboarding documentation...${NC}"

# Backup files first
echo -e "${YELLOW}Creating backups...${NC}"
for file in docs/onboarding/{DAY-1-CHECKLIST,SOCIAL-MEDIA-SETUP,AGENT-SETUP-GUIDE,META-PROMPTS-FOR-USERS,USER-JOURNEY-VALIDATION-REPORT}.md; do
  if [ -f "$file" ]; then
    cp "$file" "$file.bak"
    echo "  - Backed up: $file"
  fi
done

echo -e "${YELLOW}Applying changes...${NC}"

# Function to update a file
update_file() {
  local file=$1
  local description=$2

  if [ ! -f "$file" ]; then
    echo -e "${RED}  ✗ File not found: $file${NC}"
    return 1
  fi

  echo "  - Updating: $description"

  # Replace WTFB SAFe with SAFe (but keep SAFe Multi-Agent Development)
  sed -i 's/WTFB SAFe Multi-Agent Development/SAFe Multi-Agent Development/g' "$file"
  sed -i 's/WTFB SAFe/SAFe multi-agent/g' "$file"
  sed -i 's/the WTFB methodology/the SAFe methodology/g' "$file"

  # Replace specific GitHub URLs with placeholders
  sed -i 's|https://github\.com/ByBren-LLC/WTFB-SAFe-Agentic-Workflow|{{GITHUB_REPO_URL}}|g' "$file"
  sed -i 's|https://gitingest\.com/ByBren-LLC/WTFB-SAFe-Agentic-Workflow|https://gitingest.com/{{GITHUB_ORG}}/{{GITHUB_REPO}}|g' "$file"
  sed -i 's|git clone https://github\.com/ByBren-LLC/WTFB-SAFe-Agentic-Workflow|git clone {{GITHUB_REPO_URL}}|g' "$file"
  sed -i 's|cd WTFB-SAFe-Agentic-Workflow|cd {{PROJECT_NAME}}|g' "$file"
  sed -i 's|https://bybren-llc\.github\.io/WTFB-SAFe-Agentic-Workflow/|https://{{GITHUB_ORG}}.github.io/{{GITHUB_REPO}}/|g' "$file"

  # Replace WOR- ticket prefix with generic placeholder
  sed -i 's/WOR-\([0-9]\+\)/{{TICKET_PREFIX}}-\1/g' "$file"
  sed -i 's/WOR-326/{{TICKET_PREFIX}}-326/g' "$file"

  # Replace PROJ-1 examples with {{TICKET_PREFIX}}-1
  sed -i 's/PROJ-1/{{TICKET_PREFIX}}-1/g' "$file"

  # Keep generic GitHub URLs (like github.com/settings/tokens)
  # These are useful examples and should not be replaced

  # Clean up any double placeholder issues
  sed -i 's/{{TICKET_PREFIX}}-{{TICKET_PREFIX}}/{{TICKET_PREFIX}}/g' "$file"

  echo -e "${GREEN}  ✓ Updated: $file${NC}"
}

# Update each file
update_file "docs/onboarding/DAY-1-CHECKLIST.md" "Day 1 Checklist"
update_file "docs/onboarding/SOCIAL-MEDIA-SETUP.md" "Social Media Setup"
update_file "docs/onboarding/AGENT-SETUP-GUIDE.md" "Agent Setup Guide"
update_file "docs/onboarding/META-PROMPTS-FOR-USERS.md" "Meta-Prompts"
update_file "docs/onboarding/USER-JOURNEY-VALIDATION-REPORT.md" "User Journey Validation"

echo ""
echo -e "${GREEN}✓ All files updated successfully!${NC}"
echo ""
echo "Changes made:"
echo "  1. Replaced 'WTFB SAFe' with 'SAFe multi-agent' or 'SAFe'"
echo "  2. Replaced GitHub URLs with {{GITHUB_REPO_URL}} placeholder"
echo "  3. Replaced GitIngest URLs with {{GITHUB_ORG}}/{{GITHUB_REPO}} placeholders"
echo "  4. Replaced 'WOR-' with '{{TICKET_PREFIX}}-' for ticket references"
echo "  5. Generalized clone/cd commands with {{PROJECT_NAME}}"
echo ""
echo "Backup files created with .bak extension"
echo "To restore: for f in docs/onboarding/*.bak; do mv \"\$f\" \"\${f%.bak}\"; done"
