# ROCm Jupyter Container

This repository builds a local Podman image based on `rocm/pytorch:latest` and runs it as a Podman quadlet service with JupyterLab exposed on port `8888`.

Author: Reinaldo Moreira

The image includes:

- PyTorch with ROCm from the upstream `rocm/pytorch` image
- JupyterLab, Notebook, `ipykernel`, and `ipywidgets`
- Common data-science packages: `matplotlib`, `pandas`, `seaborn`, `scikit-learn`
- Python and Jupyter language-server packages

## Files

- [`Containerfile`](/home/reimor/rocm-jupyter/Containerfile): builds the image and installs the Jupyter/Python tooling
- [`rocm-jupyter.container`](/home/reimor/rocm-jupyter/rocm-jupyter.container): Podman quadlet unit used to run the container
- [`workspace`](/home/reimor/rocm-jupyter/workspace): local workspace directory in this repo

## Requirements

- Podman with quadlet/systemd support
- An AMD GPU with ROCm support
- Access to `/dev/kfd` and `/dev/dri`

## Build

The quadlet expects this image tag:

```bash
podman build -t localhost/rocm-pytorch-jupyter:latest .
```

## Run With Quadlet

For a user service:

```bash
mkdir -p ~/.config/containers/systemd
cp rocm-jupyter.container ~/.config/containers/systemd/
systemctl --user daemon-reload
systemctl --user enable --now rocm-jupyter.service
```

For a system-wide service, copy the unit to `/etc/containers/systemd/` and use `systemctl` without `--user`.

## What The Service Does

The quadlet currently runs the container with:

- `Network=host`
- GPU device access via `/dev/kfd` and `/dev/dri`
- `video` group membership
- `SYS_PTRACE`
- `--ipc=host`
- `seccomp=unconfined`
- A bind mount from `/home/reimor/workspace` on the host to `/workspace` in the container

JupyterLab starts with:

- host `0.0.0.0`
- port `8888`
- root allowed
- no token
- no password

Open it at:

```text
http://127.0.0.1:8888
```

## Security Note

This setup is intentionally convenient for a local machine, not hardened for shared or remote environments. Because it uses host networking and disables Jupyter authentication, do not expose it beyond a trusted local system without changing the Jupyter configuration and container runtime settings.

## Notes

- The registered kernel name is `rocm` and appears in Jupyter as `Python (ROCm)`.
- The `workspace` directory in this repo is not the path mounted by the current quadlet. The quadlet mounts `/home/reimor/workspace` instead. If you want the repo-local [`workspace`](/home/reimor/rocm-jupyter/workspace) directory mounted, update [`rocm-jupyter.container`](/home/reimor/rocm-jupyter/rocm-jupyter.container).

## License

This project is licensed under the MIT License. See [`LICENSE`](/home/reimor/rocm-jupyter/LICENSE).
