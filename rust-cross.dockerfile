FROM rust:1.77.0-slim-bookworm

RUN apt update && apt upgrade -y && \
    apt install -y git curl clang llvm xz-utils python3-venv python3-pip

ENV zigVersion "zig-linux-x86_64-0.12.0"
ENV PATH "/usr/local/zig:$PATH"

RUN curl "https://ziglang.org/download/0.12.0/$zigVersion.tar.xz" --output "$zigVersion.tar.xz" &&\
    tar -xvf "$zigVersion.tar.xz" &&\
    mv "$zigVersion" /usr/local/zig/ &&\
    rm "$zigVersion.tar.xz"

RUN pip3 install pdm
RUN cargo install cargo-zigbuild
RUN cargo install cargo-xwin
RUN cd root && cargo new tmp && cd tmp && rustup target add x86_64-pc-windows-msvc && cargo xwin check --target x86_64-pc-windows-msvc && cd .. && rm -r tmp

ENV AR_X86_64_PC_WINDOWS_MSVC="llvm-ar-11"
ENV CARGO_TARGET_X86_64_PC_WINDOWS_MSVC_RUSTFLAGS="-C linker-flavor=lld-link"