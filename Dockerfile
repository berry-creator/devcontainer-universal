ARG GO_VERSION=1.27.4
FROM golang:${GO_VERSION}-bookworm AS golang

FROM letsdone/devcontainer-base:0.1.3-all
SHELL ["/bin/zsh", "-c"]
USER root

ARG USERNAME=dev
ARG NODEJS_VERSION=24.17.0
ARG JDK_X86_64_DOWNLOAD_URL=https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-x64_bin.tar.gz
ARG JDK_AARCH64_DOWNLOAD_URL=https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-aarch64_bin.tar.gz
ARG MAVEN_DOWNLOAD_URL=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.tar.gz
ARG PALANTIR_VERSION=2.84.0

RUN set -euo pipefail; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      ripgrep; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /usr/local/go

COPY --from=golang /usr/local/go /usr/local/go

ENV GOPATH=/home/${USERNAME}/go
ENV PATH=/usr/local/go/bin:${GOPATH}/bin:${PATH}

USER ${USERNAME}
RUN set -euo pipefail; \
    mkdir -p "${GOPATH}/bin" "${GOPATH}/pkg"; \
    go version

ENV JAVA_HOME=/home/${USERNAME}/apps/jdk-21.0.2
ENV M2_HOME=/home/${USERNAME}/apps/apache-maven-3.9.9
ENV PATH=${M2_HOME}/bin:${JAVA_HOME}/bin:${PATH}
ENV NVM_DIR=/home/${USERNAME}/.nvm

RUN set -euo pipefail; \
    case "$(uname -m)" in \
      x86_64) JDK_URL="${JDK_X86_64_DOWNLOAD_URL}" ;; \
      aarch64) JDK_URL="${JDK_AARCH64_DOWNLOAD_URL}" ;; \
      *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;; \
    esac; \
    mkdir -p "${HOME}/apps"; \
    cd "${HOME}/apps"; \
    curl -fsSLo jdk.tar.gz "${JDK_URL}"; \
    tar -xzf jdk.tar.gz; \
    rm jdk.tar.gz; \
    java --version

RUN set -euo pipefail; \
    mkdir -p "${HOME}/apps"; \
    cd "${HOME}/apps"; \
    curl -fsSLo maven.tar.gz "${MAVEN_DOWNLOAD_URL}"; \
    tar -xzf maven.tar.gz; \
    rm maven.tar.gz; \
    mkdir -p "${HOME}/.m2"; \
    mvn --version

RUN set -euo pipefail; \
    curl -fsSL "https://github.com/berry-creator/palantir-java-format-all-deps/releases/download/${PALANTIR_VERSION}/palantir-java-format-all-deps-${PALANTIR_VERSION}.jar" \
      -o "${HOME}/palantir-java-format-all-deps-${PALANTIR_VERSION}.jar"; \
    printf '#!/bin/sh\nexec java -jar "$HOME/palantir-java-format-all-deps-%s.jar" --format-javadoc "$@"\n' \
      "${PALANTIR_VERSION}" > "${HOME}/palantir-cli.sh"; \
    chmod +x "${HOME}/palantir-cli.sh"

RUN source "${HOME}/.zshrc" \
    && nvm install "${NODEJS_VERSION}" \
    && nvm alias default "v${NODEJS_VERSION}" \
    && nvm use "${NODEJS_VERSION}" \
    && node_version="$(node --version)" \
    && echo "Installed Node.js ${node_version}" \
    && [ "${node_version}" = "v${NODEJS_VERSION}" ] \
    && printf '\nnvm use --silent default\n' >> "${HOME}/.zshrc"

ARG CLAUDE_PREINSTALLED=false
RUN if [ "${CLAUDE_PREINSTALLED}" = "true" ]; then \
      source "${HOME}/.zshrc" && install_claude; \
    fi

ARG GEMINI_PREINSTALLED=false
RUN if [ "${GEMINI_PREINSTALLED}" = "true" ]; then \
      source "${HOME}/.zshrc" && install_gemini_cli; \
    fi

ARG CODEX_PREINSTALLED=false
RUN if [ "${CODEX_PREINSTALLED}" = "true" ]; then \
      source "${HOME}/.zshrc" && install_codex; \
    fi

WORKDIR /home/${USERNAME}/workspace
ENTRYPOINT ["/bin/zsh"]
