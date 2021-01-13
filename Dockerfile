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
RUN apt install -y clang-tools-10

RUN wget -O VulkanSDK.tar.gz https://sdk.lunarg.com/sdk/download/1.2.162.1/linux/vulkansdk-linux-x86_64-1.2.162.1.tar.gz?u=true && \
     mkdir VulkanSDK && \
     cd VulkanSDK && \
     tar xvf /VulkanSDK.tar.gz

RUN	cd VulkanSDK/1.2.162.1
ENV	VULKAN_SDK="/VulkanSDK/1.2.162.1/x86_64${VULKAN_SDK}"
ENV	LD_LIBRARY_PATH="${VULKAN_SDK}/lib:${LD_LIBRARY_PATH}"
ENV	VK_LAYER_PATH="${VULKAN_SDK}/etc/explicit_layer.d:${VK_LAYER_PATH}"
ENV	PATH="${VULKAN_SDK}/bin:${PATH}"

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.48.0

RUN set -eux; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libc6-dev \
        ; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='49c96f3f74be82f4752b8bffcf81961dea5e6e94ce1ccba94435f12e871c3bdb' ;; \
        armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='5a2be2919319e8778698fa9998002d1ec720efe7cb4f6ee4affb006b5e73f1be' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='d93ef6f91dab8299f46eef26a56c2d97c66271cea60bf004f2f088a86a697078' ;; \
        i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='e3d0ae3cfce5c6941f74fed61ca83e53d4cd2deb431b906cbd0687f246efede4' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.22.1/${rustArch}/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
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

RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang-10 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-10 100