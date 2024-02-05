#!/usr/bin/env bash

# tier 1
# https://doc.rust-lang.org/rustc/platform-support.html
targets=(
  aarch64-unknown-linux-gnu
  i686-pc-windows-gnu
  i686-pc-windows-msvc
  i686-unknown-linux-gnu
  x86_64-apple-darwin
  x86_64-pc-windows-gnu
  x86_64-pc-windows-msvc
  x86_64-unknown-linux-gnu
)

ROOT_DIR="$(cd `dirname $0`; pwd)"
OUTPUT="${OUTPUT:-/tmp/cross-compile.out}"

export CARGO_BUILD_TARGET="${1:-aarch64-unknown-linux-gnu}"
export CC=${ROOT_DIR}/zigcc
export CXX=${ROOT_DIR}/zigcxx

function gen_conf() {
  mkdir -p .cargo
  echo "[target.$CARGO_BUILD_TARGET]" > .cargo/config
  echo "linker = \"${CC}\"" >> .cargo/config
}

echo "Running ${CARGO_BUILD_TARGET}.................."

rustup target add "${CARGO_BUILD_TARGET}"
gen_conf "${CARGO_BUILD_TARGET}"

function run() {
  MODE="$1"
  PROJECT=$(basename `pwd`)
  cargo clean

  if [[ "$MODE" == "zigcc" ]]; then
    cargo build
  else
    cargo zigbuild --target ${CARGO_BUILD_TARGET}
  fi

  if [ $? -eq 0 ]; then
    echo "| ${CARGO_BUILD_TARGET} | ${PROJECT} | ${MODE}| ✅ |" >> $OUTPUT
  else
    echo "| ${CARGO_BUILD_TARGET} | ${PROJECT} | ${MODE}| ❌ |" >> $OUTPUT
  fi
}

PROJECT=( "hello-world" "reqwest" "rocksdb" )
for DIR in "${PROJECT[@]}"; do
  cd ${ROOT_DIR}/${DIR}
  run zigcc
  run zigbuild
done
