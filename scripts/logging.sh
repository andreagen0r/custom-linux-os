WHITE='\033[0;37m'
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"
UNDERLINE='\033[4m'

log_title() {
    local LINE_WIDTH=80
    printf "\n${CYAN}${UNDERLINE}%-*s${NC}\n" "$LINE_WIDTH" "${*^^}"
}
log_title_error() {
    local LINE_WIDTH=80
    printf "\n${RED}${UNDERLINE}%-*s${NC}\n" "$LINE_WIDTH" "${*^^}"
}
log_info()    { echo -e "${WHITE}[  INFO   ] $*${NC}";        }
log_success() { echo -e "${GREEN}[ SUCCESS ] $*${NC}";    }
log_warn()    { echo -e "${YELLOW}[  WARN   ] $*${NC}";      }
log_error()   { echo -e "${RED}[  ERROR  ] $*${NC}";         }
log_debug()   { echo -e "${BLUE}[  DEBUG  ] $*${NC}";       }