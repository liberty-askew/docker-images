FROM rust:1.78-slim-bookworm

# Install necessary dependencies, including protobuf-compiler and sccache
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget apt-transport-https protobuf-compiler ca-certificates git curl \
    clang llvm lld xz-utils python3-venv python3-pip perl-base libperl5.36 sccache \
    && wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update && apt-get install -y --no-install-recommends dotnet-runtime-7.0 \
    && rm -rf /var/lib/apt/lists/* \
    && rm packages-microsoft-prod.deb

RUN which sccache || cargo install sccache

ENV SCCACHE_DIR="/root/.cache/sccache"
ENV RUSTC_WRAPPER="sccache"
ENV CARGO_NET_GIT_FETCH_WITH_CLI="true"

ENV zigVersion="zig-linux-x86_64-0.12.0"
ENV PATH="/usr/local/zig:$PATH"
RUN curl -fsSL "https://ziglang.org/download/0.12.0/$zigVersion.tar.xz" -o "$zigVersion.tar.xz" \
    && tar -xf "$zigVersion.tar.xz" \
    && mv "$zigVersion" /usr/local/zig/ \
    && rm "$zigVersion.tar.xz"

RUN python3 -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --no-cache-dir pdm

ENV PATH="/opt/venv/bin:$PATH"

RUN cargo install cargo-zigbuild \
    && cargo install cargo-xwin

RUN mkdir -p /tmp/cargo_check && cd /tmp/cargo_check \
    && cargo new tmp_project \
    && cd tmp_project \
    && rustup target add x86_64-pc-windows-msvc \
    && cargo xwin check --target x86_64-pc-windows-msvc \
    && cd / && rm -rf /tmp/cargo_check

ENV AR_X86_64_PC_WINDOWS_MSVC="llvm-ar-11"
ENV CARGO_TARGET_X86_64_PC_WINDOWS_MSVC_RUSTFLAGS="-C linker-flavor=lld-link"

WORKDIR /app
