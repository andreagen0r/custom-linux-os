#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"

log_success() { echo -e "${GREEN}[SUCCESS] $*${NC}";    }
log_info()    { echo -e "${CYAN}$*${NC}";        }
log_warn()    { echo -e "${YELLOW}[WARN] $*${NC}";      }
log_error()   { echo -e "${RED}[ERRO] $*${NC}";         }
log_debug()   { echo -e "${BLUE}[DEBUG] $*${NC}";       }