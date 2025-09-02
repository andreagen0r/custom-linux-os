#!/bin/bash

set -e                  # Exit on error
set -o pipefail         # Exit on pipeline error
set -u                  # Treat unset variable as error

# Define current source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Include logging functions
source $SCRIPT_DIR/logging.sh

if [ -z "$1" ]; then
    log_error "Error: No parameters provided."
    log_info "Use: $0 <directory>"
    exit 1
fi

if [ ! -d "$1" ]; then
    log_error "Error: '$1' is not a valid directory."
    exit 1
fi

LC_ALL=C 
PATH=/usr/bin:/bin

export PATH="/usr/sbin:/sbin:$PATH"

bail() { log_error "FATAL: $1"; exit 1; }
grep --version > /dev/null 2> /dev/null || bail "grep does not work"
sed '' /dev/null || bail "sed does not work"
sort   /dev/null || bail "sort does not work"

ver_check() {
    local name="$1"
    local cmd="$2"
    local req_ver="$3"
    local v=""

   if ! command -v "$cmd" &>/dev/null; then
      printf "${RED}[  ERROR  ] Cannot find %s (%s)${NC}\n" "$cmd" "$name"
      return 1
   fi

   local getVersionRegx='[0-9]+\.[0-9]+(\.[0-9]+)?'

   if v=$("$cmd" --version 2>&1 | grep -oE $getVersionRegx | head -n1); then
      : 
   elif v=$("$cmd" -version 2>&1 | grep -oE $getVersionRegx | head -n1); then
      : 
   else
      printf "${RED}[  ERROR  ] Unable to get version for %s (%s)${NC}\n" "$cmd" "$name"
      return 1
   fi


   if [ -z "$v" ]; then
      printf "${RED}[  ERROR  ] Unable to parse version for %s (%s)${NC}\n" "$cmd" "$name"
      return 1
   fi


   if printf '%s\n' "$req_ver" "$v" | sort -V -C &>/dev/null; then
      printf "${GREEN}[ SUCCESS ] %-20s %-10s >= %s${NC}\n" "$name" "$v" "$req_ver"
      return 0
   else
      printf "${RED}[  ERROR  ] %s %s is TOO OLD (%s or later required)${NC}\n" "$name" "$v" "$req_ver"
      return 1
   fi
}

ver_kernel() {
   kver=$(uname -r | grep -E -o '^[0-9\.]+')
   if printf '%s\n' $1 $kver | sort --version-sort --check &>/dev/null
   then 
     log_success "Linux Kernel $kver >= $1"; return 0;
   else 
     log_error "Linux Kernel ($kver) is TOO OLD ($1 or later required)\n"; 
     return 1; 
   fi
}

alias_check() {
   if $1 --version 2>&1 | grep -qi "$2"; then
      log_success $1 is $2
   else
      log_error "$1 is NOT $2\n ${3:+      Tip: $3}"
   fi
}


# Coreutils first because --version-sort needs Coreutils >= 7.0
ver_check Coreutils           sort                  8.1 || bail "Coreutils too old, stop"
ver_kernel 5.14 

CHECKS_FILE="$PARENT_DIR/$1/checks.txt"

while IFS= read -r line; do
    # Ignore empty lines or lines starting with #
    [ -z "$line" ] && continue
    [[ "$line" =~ ^# ]] && continue

    parsed_line=$(echo "$line" | sed -E 's/(.*)\s+(\S+)\s+(\S+)$/\1|\2|\3/')

    IFS='|' read -r nome cmd versao <<< "$parsed_line"
    
    nome="${nome//\"/}" # Remove aspas
    nome=$(echo "$nome" | sed 's/^[ \t]*//;s/[ \t]*$//') # trim

    ver_check "$nome" "$cmd" "$versao"

# Read the file
done < "$CHECKS_FILE"

#*******************************************
log_title "Kernel check"
#*******************************************
if mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]
then log_success "Linux Kernel supports UNIX 98 PTY";
else log_warn "Linux Kernel does NOT support UNIX 98 PTY"; fi

#*******************************************
log_title "Symlink check"
#*******************************************
alias_check sh Bash "Remove de symlink with \"sudo rm /bin/sh\" and add new symlink \"sudo ln -s /bin/bash /bin/sh\""

#*******************************************
log_title "Compiler check"
#*******************************************
if printf "int main(){}" | g++ -x c++ -
then log_success "g++ works";
else log_error "g++ does NOT work"; fi
rm -f a.out

#*******************************************
log_title "Processing units available"
#*******************************************
if [ "$(nproc)" = "" ]; then
   log_error "nproc is not available or it produces empty output"
else
   log_success "$(nproc) logical cores are available"
fi