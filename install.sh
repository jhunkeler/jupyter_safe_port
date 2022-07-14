#!/usr/bin/env bash

function usage() {
    printf "Options:
  --help (-h)   Display this message
  --prefix      Path to install (default: $prefix)
  --destdir     A container directory (for packaging)\n"
}

# Assign default paths if not modified by the user
[[ -z "${prefix}" ]] && prefix="/usr/local"
[[ -z "${destdir}" ]] && destdir=""

# Parse arguments
i=0
argv=($@)
nargs=${#argv[@]}
while [[ $i < $nargs ]]; do
    key="${argv[$i]}"
    if [[ "$key" =~ '=' ]]; then
        value=${key#*=}
        key=${key%=*}
    else
        value="${argv[$i+1]}"
    fi
    case "$key" in
        --help|-h)
            usage
            exit 0
            ;;
        --prefix)
            prefix="$value"
            (( i++ ))
            ;;
        --destdir)
            destdir="$value"
            (( i++ ))
            ;;
    esac
    (( i++ ))
done

set -e
dest="${destdir}${prefix}"
mkdir -p "${dest}"/bin
for src in bin/*; do
    x="$(basename $src)"
    echo "Installing $x in $dest"/bin
    install -m755 "$src" "$dest"/bin
done
echo done
