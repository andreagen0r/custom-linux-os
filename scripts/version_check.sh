#!/bin/bash

LC_ALL=C 
PATH=/usr/bin:/bin

bail() { log_error "FATAL: $1"; exit 1; }
grep --version > /dev/null 2> /dev/null || bail "grep does not work"
sed '' /dev/null || bail "sed does not work"
sort   /dev/null || bail "sort does not work"

ver_check()
{
   if ! type -p $2 &>/dev/null
   then 
     printf "❌: Cannot find $2 ($1)"; return 1; 
   fi

  if $2 --version &>/dev/null
   then
     v=$($2 --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
   elif $2 -version &>/dev/null
   then
     v=$($2 -version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
   else
      printf "❌: Unable to get version for $2 ($1)\n"
      return 1
   fi

   if printf '%s\n' $3 $v | sort --version-sort --check &>/dev/null
   then 
     printf "✅: %-9s %-6s >= $3\n" "$1" "$v"; return 0;
   else 
     printf "❌: %-9s is TOO OLD ($3 or later required)\n" "$1"; 
     return 1; 
   fi
}

ver_kernel()
{
   kver=$(uname -r | grep -E -o '^[0-9\.]+')
   if printf '%s\n' $1 $kver | sort --version-sort --check &>/dev/null
   then 
     printf "✅: Linux Kernel $kver >= $1\n"; return 0;
   else 
     printf "❌: Linux Kernel ($kver) is TOO OLD ($1 or later required)\n" "$kver"; 
     return 1; 
   fi
}

alias_check() {
   if $1 --version 2>&1 | grep -qi "$2"; then
      # printf "✅: %-4s is %-10s%s\n" "$1" "$2" "${3:+ - $3}"
      printf "✅: %-4s is $2\n" "$1";
   else
      printf "❌: %-4s is NOT %-6s%s\n" "$1" "$2" "${3:+ - $3}"
   fi
}

log_info "Tools"
# Coreutils first because --version-sort needs Coreutils >= 7.0
ver_check Coreutils           sort                  8.1 || bail "Coreutils too old, stop"
ver_check Bash                bash                  3.2
ver_check Binutils            ld                    2.13.1
ver_check Xorriso             xorriso               1.5.6
ver_check Squashfs-tools      mksquashfs            4.6.1
ver_check Mtools              mtools                4.0.43
ver_check Sed                 sed                   4.1.5
ver_check Tar                 tar                   1.22
ver_check Xz                  xz                    5.0.0
ver_check GCC                 gcc                   5.2
ver_check "GCC (C++)"         g++                   5.2
ver_check Grep                grep                  2.5.1a
ver_check Gzip                gzip                  1.3.12
ver_check Make                make                  4.0
# ver_check Mkfs-vfat           mkfs.vfat             4.2 # TODO: corrigir
# ver_check Debootstrap         debootstrap           1.0.13
# ver_check Grub-pc-bin         grub-pc-bin 
# ver_check Grub-efi-ia32-bin   grub-efi-ia32-bin 
# ver_check Grub-efi-amd64-bin  grub-efi-amd64-bin 
# ver_check Bison          bison    2.7
# ver_check Diffutils      diff     2.8.1
# ver_check Findutils      find     4.2.31
# ver_check Gawk           gawk     4.0.1
# ver_check M4             m4       1.4.10
# ver_check Patch          patch    2.5.4
# ver_check Perl           perl     5.8.8
# ver_check Python         python3  3.4
# ver_check Texinfo        texi2any 5.0
ver_kernel 5.4 

if mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]
then echo "✅: Linux Kernel supports UNIX 98 PTY";
else echo "❌: Linux Kernel does NOT support UNIX 98 PTY"; fi


log_info "Aliases:"
alias_check sh Bash "Remove de symlink with \"sudo rm /bin/sh\" and add new symlink \"sudo ln -s /bin/bash /bin/sh\""

log_info "Compiler check:"
if printf "int main(){}" | g++ -x c++ -
then echo "✅: g++ works";
else echo "❌: g++ does NOT work"; fi
rm -f a.out

if [ "$(nproc)" = "" ]; then
   echo "❌: nproc is not available or it produces empty output"
else
   echo "✅: nproc reports $(nproc) logical cores are available"
fi