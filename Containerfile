# Podmanfile (Dockerfile-compatible)
# Base: ROCm PyTorch official image
FROM docker.io/rocm/pytorch:latest

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# ---- System deps ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-dev \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ---- Python / Jupyter stack ----
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    pip install \
        jupyterlab \
        notebook \
        ipykernel \
        ipywidgets \
        matplotlib \
        pandas \
        seaborn \
        scikit-learn \
        python-lsp-server[all] \
        jupyter-lsp \
        jedi \
        jedi-language-server

# Register kernel explicitly (helps when multiple envs exist)
RUN python3 -m ipykernel install --name rocm --display-name "Python (ROCm)"

# ---- Workspace ----
WORKDIR /workspace

# ---- Jupyter config (no token, bind all interfaces) ----
# For lab use; DO NOT expose without network isolation (you're using --network=host)
RUN mkdir -p /root/.jupyter && \
    printf "c.ServerApp.ip = '0.0.0.0'\n\
c.ServerApp.port = 8888\n\
c.ServerApp.open_browser = False\n\
c.ServerApp.allow_root = True\n\
c.ServerApp.token = ''\n\
c.ServerApp.password = ''\n" > /root/.jupyter/jupyter_server_config.py

# ---- Expose (informational; host networking ignores this) ----
EXPOSE 8888

# ---- Default command ----
CMD ["jupyter", "lab"]
