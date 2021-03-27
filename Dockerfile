FROM amd64/ubuntu:20.10

RUN apt update
RUN apt install -y libglm-dev libxcb-dri3-0 libxcb-present0
RUN apt install -y libpciaccess0 libpng-dev libxcb-keysyms1-dev
RUN apt install -y libxcb-dri3-dev libx11-dev libmirclient-dev
RUN apt install -y libwayland-dev libxrandr-dev
RUN apt install -y libglfw3-dev
RUN apt install -y git
RUN apt install -y python
RUN apt install -y wget
RUN apt install -y cmake
RUN apt install -y gcc g++
RUN apt install -y clang-tools-11

RUN wget -O VulkanSDK.tar.gz https://sdk.lunarg.com/sdk/download/1.2.170.0/linux/vulkansdk-linux-x86_64-1.2.170.0.tar.gz?u=true && \
     mkdir VulkanSDK && \
     cd VulkanSDK && \
     tar xvf /VulkanSDK.tar.gz

RUN	cd VulkanSDK/1.2.170.0
ENV	VULKAN_SDK="/VulkanSDK/1.2.170.0/x86_64${VULKAN_SDK}"
ENV	LD_LIBRARY_PATH="${VULKAN_SDK}/lib:${LD_LIBRARY_PATH}"
ENV	VK_LAYER_PATH="${VULKAN_SDK}/etc/explicit_layer.d:${VK_LAYER_PATH}"
ENV	PATH="${VULKAN_SDK}/bin:${PATH}"

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.51.0

RUN set -eux; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libc6-dev \
        ; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu';; \
        armhf) rustArch='armv7-unknown-linux-gnueabihf';; \
        arm64) rustArch='aarch64-unknown-linux-gnu';; \
        i386) rustArch='i686-unknown-linux-gnu';; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.23.1/${rustArch}/rustup-init"; \
    wget "$url"; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version; \
    apt-get remove -y --auto-remove \
        wget \
        ; \
    rm -rf /var/lib/apt/lists/*;

RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang-11 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-11 100