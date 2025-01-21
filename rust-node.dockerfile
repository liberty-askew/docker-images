FROM rust:1.77.0-slim-bookworm

# Update and install required dependencies
RUN apt update && apt upgrade -y && \
    apt install -y --no-install-recommends \
    git curl clang llvm xz-utils python3-venv python3-pip \
    mingw-w64 pkg-config libssl-dev perl-base libperl5.36 wget && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 18.x and pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt install -y nodejs && \
    corepack enable && \
    corepack prepare pnpm@latest-8 --activate

# Set up Zig
ENV ZIG_VERSION="zig-linux-x86_64-0.12.0"
ENV PATH="/usr/local/zig:$PATH"
RUN curl -L "https://ziglang.org/download/0.12.0/$ZIG_VERSION.tar.xz" | tar -xJ && \
    mv "$ZIG_VERSION" /usr/local/zig/

# Set up Python virtual environment for PDM
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir pdm

# Ensure virtual environment is in the PATH
ENV PATH="/opt/venv/bin:$PATH"
ENV PATH="/opt/venv/bin:$PATH"


RUN cargo install --locked cargo-zigbuild cargo-xwin sccache

RUN cd root && cargo new tmp && cd tmp && rustup target add x86_64-pc-windows-gnu x86_64-pc-windows-msvc && \
    cargo xwin check --target x86_64-pc-windows-msvc

ENV AR_X86_64_PC_WINDOWS_MSVC="llvm-ar-11"
ENV CARGO_TARGET_X86_64_PC_WINDOWS_MSVC_RUSTFLAGS="-C linker-flavor=lld-link"

ENV CARGO_HOME=/usr/local/cargo
ENV SCCACHE_DIR=/root/.cache/sccache
ENV RUSTC_WRAPPER=sccache
