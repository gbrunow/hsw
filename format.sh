# !/bin/bash

print_usage() {
  echo "Usage: $0 [--all | file_path]"
  echo ""
  echo "--all        Run command for all source files"
  echo "file_path    Format a specific file"
}

if [[ $# -eq 0 ]]; then
  print_usage
  exit 1
fi

if [[ "$1" == "--all" ]]; then
  echo "Formatting all files"
  find src -type f -name "*.scad" -exec .dev/scadformat "{}" \; # format all source files
  wait
else
  # The file path is the second argument
  file_path=$1
  
  echo "Formatting file: $file_path"
  .dev/scadformat "$file_path" # format file
  wait
fi

find src -type f -name "*.scadbak" -exec rm {} + # remove backup files