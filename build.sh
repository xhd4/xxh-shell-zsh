#!/usr/bin/env bash

CDIR="$(cd "$(dirname "$0")" && pwd)"

while getopts A:K:q option
do
  case "${option}"
  in
    q) QUIET=1;;
    A) ARCH=${OPTARG};;
    K) KERNEL=${OPTARG};;
  esac
done

build_dir=$CDIR/build

rm -rf $build_dir
mkdir -p $build_dir/zsh-bin

for f in entrypoint.sh zsh.sh
do
    cp $CDIR/$f $build_dir/
done
cp $CDIR/zshrc $build_dir/.zshrc

# tag=$(curl --silent https://api.github.com/repos/romkatv/zsh-bin/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
tag=v6.1.1
zsh_verion=5.8
# platform=$(uname | tr '[:upper:]' '[:lower:]')
# arch=$(uname -m)

linux_x64=linux-x86_64
darwin_x64=darwin-x86_64
linux_aarch64=linux-aarch64
darwin_arm64=darwin-arm64

declare -A distfileArray=(
  ["zsh-${zsh_verion}-$linux_x64"]=$linux_x64
  ["zsh-${zsh_verion}-$darwin_x64"]=$darwin_x64
  ["zsh-${zsh_verion}-$linux_aarch64"]=$linux_aarch64
  ["zsh-${zsh_verion}-$darwin_arm64"]=$darwin_arm64
)

cd $build_dir/zsh-bin

[ $QUIET ] && arg_q='-q' || arg_q=''
[ $QUIET ] && arg_s='-s' || arg_s=''
[ $QUIET ] && arg_progress='' || arg_progress='--show-progress'

for distfile in ${!distfileArray[@]}; do
  url="https://github.com/romkatv/zsh-bin/releases/download/$tag/$distfile.tar.gz"

  tarname=`basename $url`

  if [ -x "$(command -v wget)" ]; then
    wget $arg_q $arg_progress $url -O $tarname
  elif [ -x "$(command -v curl)" ]; then
    curl $arg_s -L $url -o $tarname
  else
    echo Install wget or curl
  fi

  mkdir -p "${distfileArray[$distfile]}"
  tar -xzf $tarname -C "${distfileArray[$distfile]}"
  rm -rf $tarname

done