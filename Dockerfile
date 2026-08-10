FROM ubuntu:24.04@sha256:561618e2c15bf2397621dd04f96926663a3b5616c189cf7e38db7e82f5c538ea

USER root

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        gcc-12 \
        g++-12 \
        gcc-14 \
        g++-14 \
    && rm -rf /var/lib/apt/lists/*

# Make GCC 14 the default compiler for Bazel host toolchain discovery.
RUN ln -sf /usr/bin/gcc-14 /usr/local/bin/gcc \
    && ln -sf /usr/bin/g++-14 /usr/local/bin/g++

# Install LLVM 21 and LLVM 22.
RUN curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key \
      | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] " \
            "http://apt.llvm.org/noble/ llvm-toolchain-noble-21 main" \
    > /etc/apt/sources.list.d/llvm-21.list \
    && echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] " \
            "http://apt.llvm.org/noble/ llvm-toolchain-noble-22 main" \
    > /etc/apt/sources.list.d/llvm-22.list \
      && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        --no-install-recommends \
        clang-21 \
        lld-21 \
        llvm-21 \
        libclang-rt-21-dev \
        clang-22 \
        lld-22 \
        llvm-22 \
        libclang-rt-22-dev \
    && ln -sf /usr/bin/llvm-symbolizer-22 /usr/local/bin/llvm-symbolizer \
    && rm -rf /var/lib/apt/lists/*

# Sanity check exactly the Bazel toolchains we register.
RUN test -x /usr/bin/gcc-12 \
    && test -x /usr/bin/g++-12 \
    && test -x /usr/bin/gcc-14 \
    && test -x /usr/bin/g++-14 \
    && test -x /usr/bin/clang-21 \
    && test -x /usr/bin/clang++-21 \
    && test -x /usr/bin/ld.lld-21 \
    && test -x /usr/bin/clang-22 \
    && test -x /usr/bin/clang++-22 \
    && test -x /usr/bin/ld.lld-22 \
    && test -x /usr/local/bin/gcc \
    && test -x /usr/local/bin/g++

ARG TARGETARCH
ARG BAZELISK_VERSION=1.25.0
ARG GITHUB_MIRROR=https://github.com

RUN case "$TARGETARCH" in \
      amd64) arch=amd64 ;; \
      arm64) arch=arm64 ;; \
      *) echo "Unsupported architecture: $TARGETARCH"; exit 1 ;; \
    esac \
    && curl -fsSL \
      "${GITHUB_MIRROR}/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-${arch}" \
      -o /usr/local/bin/bazelisk \
    && chmod 0755 /usr/local/bin/bazelisk \
    && ln -sf /usr/local/bin/bazelisk /usr/local/bin/bazel

ENV BAZELISK_BASE_URL="${GITHUB_MIRROR}/bazelbuild/bazel/releases/download"

# Configure sanitizer symbolization.
ENV ASAN_SYMBOLIZER_PATH=/usr/local/bin/llvm-symbolizer
ENV MSAN_SYMBOLIZER_PATH=/usr/local/bin/llvm-symbolizer
ENV TSAN_OPTIONS="external_symbolizer_path=/usr/local/bin/llvm-symbolizer"

# Avoid Bazel convenience symlink permission problems when /workspace
# is bind-mounted from the host.
ENV BAZEL_SYMLINK_PREFIX=/tmp/bazel-

# Create an unprivileged runtime user.
RUN groupadd --gid 10001 bazeluser \
    && useradd \
        --uid 10001 \
        --gid bazeluser \
        --create-home \
        --shell /bin/bash \
        bazeluser

WORKDIR /workspace

RUN chown bazeluser:bazeluser /workspace

USER bazeluser

ENTRYPOINT []
CMD ["/bin/bash"]
