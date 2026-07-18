#!/usr/bin/env bash
set -euo pipefail

echo "==> Deploying global compiler gaslight wrappers for v3 architecture..."

# 1. C/C++ Compilers (GCC & Clang)
# These use -march=native and -mtune=native
cat << 'EOF' | tee /usr/local/bin/gcc /usr/local/bin/g++ /usr/local/bin/cc /usr/local/bin/c++ /usr/local/bin/clang /usr/local/bin/clang++ > /dev/null
#!/bin/bash
NEW_ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "-march=native" || "$arg" == "-mtune=native" ]]; then
        NEW_ARGS+=("${arg//native/x86-64-v3}")
    else
        NEW_ARGS+=("$arg")
    fi
done
COMPILER_NAME=$(basename "$0")
exec "/usr/bin/$COMPILER_NAME" "${NEW_ARGS[@]}"
EOF

# 2. Rust Compiler (rustc & cargo)
# Rust uses target-cpu=native instead of march
cat << 'EOF' | tee /usr/local/bin/rustc > /dev/null
#!/bin/bash
NEW_ARGS=()
for arg in "$@"; do
    if [[ "$arg" == "target-cpu=native" ]]; then
        NEW_ARGS+=("target-cpu=x86-64-v3")
    else
        NEW_ARGS+=("$arg")
    fi
done
exec "/usr/bin/rustc" "${NEW_ARGS[@]}"
EOF

# 3. Make them all executable
chmod +x /usr/local/bin/gcc /usr/local/bin/g++ /usr/local/bin/cc /usr/local/bin/c++
chmod +x /usr/local/bin/clang /usr/local/bin/clang++ /usr/local/bin/rustc

# 4. Go Compiler (Go uses env vars for architecture leveling)
# We export this to the system profile so build scripts pick it up
echo "export GOAMD64=v3" > /etc/profile.d/go-v3-gaslight.sh

echo "==> Hardware gaslighting active. All compilations will now target x86-64-v3."
