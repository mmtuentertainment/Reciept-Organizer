#!/bin/bash

# Test Modules Runner Script
# 
# Makes it easy to run modular tests without timeouts
#
# Usage:
#   ./test_modules.sh --list                    # List all modules
#   ./test_modules.sh --module mocks            # Run mocks module
#   ./test_modules.sh --all                     # Run all modules sequentially
#   ./test_modules.sh --stable                  # Run only stable modules
#   ./test_modules.sh --fix                     # Run and fix failing modules

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
MODULE=""
ACTION="run"

while [[ $# -gt 0 ]]; do
  case $1 in
    --list|-l)
      ACTION="list"
      shift
      ;;
    --module|-m)
      MODULE="$2"
      shift 2
      ;;
    --all|-a)
      ACTION="all"
      shift
      ;;
    --stable|-s)
      ACTION="stable"
      shift
      ;;
    --fix|-f)
      ACTION="fix"
      shift
      ;;
    --help|-h)
      echo "Test Modules Runner"
      echo ""
      echo "Usage:"
      echo "  ./test_modules.sh [options]"
      echo ""
      echo "Options:"
      echo "  --list, -l              List all available modules"
      echo "  --module, -m <name>     Run specific module"
      echo "  --all, -a               Run all modules sequentially"
      echo "  --stable, -s            Run only stable modules"
      echo "  --fix, -f               Interactive fix mode"
      echo "  --help, -h              Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Function to run a module
run_module() {
  local module_name=$1
  echo -e "\n${YELLOW}Running module: $module_name${NC}"
  
  if dart test/test_modules/run_module.dart --module "$module_name"; then
    echo -e "${GREEN}✅ Module $module_name passed${NC}"
    return 0
  else
    echo -e "${RED}❌ Module $module_name failed${NC}"
    return 1
  fi
}

# Execute based on action
case $ACTION in
  list)
    dart test/test_modules/run_module.dart --list
    ;;
    
  run)
    if [ -z "$MODULE" ]; then
      echo "Error: Module name required"
      echo "Use --list to see available modules"
      exit 1
    fi
    run_module "$MODULE"
    ;;
    
  all)
    echo -e "${YELLOW}Running all test modules...${NC}\n"
    
    # Define all modules in order
    modules=(
      "mocks"
      "core"
      "domain"
      "widgets"
      "settings"
      "capture"
      "receipts"
      "export"
      "integration"
      "performance"
    )
    
    passed=0
    failed=0
    failed_modules=()
    
    for module in "${modules[@]}"; do
      if run_module "$module"; then
        ((passed++))
      else
        ((failed++))
        failed_modules+=("$module")
      fi
    done
    
    echo -e "\n${YELLOW}========== Summary ==========${NC}"
    echo -e "Modules passed: ${GREEN}$passed${NC}"
    echo -e "Modules failed: ${RED}$failed${NC}"
    
    if [ ${#failed_modules[@]} -gt 0 ]; then
      echo -e "\n${RED}Failed modules:${NC}"
      for module in "${failed_modules[@]}"; do
        echo "  - $module"
      done
    fi
    ;;
    
  stable)
    echo -e "${YELLOW}Running stable modules only...${NC}\n"
    
    stable_modules=("mocks" "core" "settings")
    
    for module in "${stable_modules[@]}"; do
      run_module "$module"
    done
    ;;
    
  fix)
    echo -e "${YELLOW}Interactive fix mode${NC}"
    echo "This will run each module and help you fix failures"
    
    modules=(
      "mocks"
      "core"
      "domain"
      "widgets"
      "settings"
      "capture"
      "receipts"
      "export"
      "integration"
      "performance"
    )
    
    for module in "${modules[@]}"; do
      echo -e "\n${YELLOW}Testing module: $module${NC}"
      
      if run_module "$module"; then
        echo -e "${GREEN}Module $module is working!${NC}"
      else
        echo -e "${RED}Module $module has failures${NC}"
        echo -n "Do you want to skip (s), retry (r), or quit (q)? "
        read -r response
        
        case $response in
          s|S)
            echo "Skipping $module"
            continue
            ;;
          r|R)
            echo "Retrying $module"
            run_module "$module"
            ;;
          q|Q)
            echo "Quitting"
            exit 0
            ;;
        esac
      fi
    done
    ;;
esac