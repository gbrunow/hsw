#!/bin/bash

# ******************************************************************************
# * Setup script that install required libraries and development dependencies. *
# * It will remove and reinstall all of its dependencies on every run.         *
# *   - unzip                                                                  *
# *     - brew install unzip (macos)                                           *
# *     - sudo apt-get install unzip (linux)                                   *
# ******************************************************************************

ROOT=$(pwd)
OS=$(uname -s)

# ***************************
# *        libraries        *
# ***************************

rm -rf libs
mkdir libs
cd libs

# BOSL2 does not have formal releases
# - checkout library on whatever state was on July 19th 2024
git clone https://github.com/BelfrySCAD/BOSL2.git
cd BOSL2
git checkout 8383d360cceddd447cb25e4564d8a3b363f5fd82

# ****************************
# *     dev dependencies     *
# ****************************

cd $ROOT

rm -rf .dev
mkdir .dev
cd .dev

base_url=https://github.com/hugheaves/scadformat/releases/download/v0.6
file_name=scadformat.zip

if [[ "$OS" == "Darwin" ]]; then
  file_url="$base_url/macos.zip"
  elif [[ "$OS" == "Linux" ]]; then
  file_url="$base_url/linux.zip"
else
  echo "Unsupported operating system: $os"
  exit 1
fi

echo "Downloading $file_name from $file_url..."
curl -L -o "$file_name" "$file_url"

echo "Extracting file"
unzip $file_name
rm $file_name


# python3 -m venv venv
# source ./venv/bin/activate
# python -m pip install --upgrade pip
# pip install antlr4-tools

# git clone https://github.com/hugheaves/scadformat.git
# cd scadformat
# make