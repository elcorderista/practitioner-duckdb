FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl wget git unzip \
    python3 python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://opencode.ai/install | bash

RUN curl -fsSL https://install.duckdb.org | sh

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:/root/.opencode/bin:/root/.duckdb/cli/latest:${PATH}"
