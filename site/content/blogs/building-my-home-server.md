---
title: "Building My Home Server: ZFS, Docker, and GitHub Automation"
date: 2025-07-14
tags: ["homelab", "server", "zfs", "docker", "github", "pikvm"]
summary: "Setting up an Ubuntu 24.04 LTS home server using repurposed gaming hardware, mirrored ZFS-on-root, Docker Compose stacks, PiKVM for remote management, and GitHub for configuration control."
draft: false
---

After getting my router stable and running OPNsense, the next piece of my homelab puzzle was the main server — the brain of everything. I wanted something that could run 24/7, handle Docker workloads, store data safely, and stay recoverable no matter what. The goal wasn’t just make it work, but make it stable enough that I don’t have to think about it.

## Repurposing Old Hardware

The foundation for the server is my old gaming PC — a solid Intel system with 16 GB of RAM, a decent motherboard, and good thermals. Instead of letting it sit unused, I stripped it down, removed the GPU, cleaned it up, and reused it as a headless server. I also swapped the overpowered gaming PSU for a quieter, more efficient one designed for continuous operation.

Reusing the gaming hardware had a few big advantages:
- Plenty of CPU headroom for Docker workloads and future VMs.
- Zero new cost. It’s built entirely from parts I already owned.
- Reliability. Desktop-class components with proper cooling are fine for homelab duty.

It’s not rack-mounted or flashy — just a quiet, self-contained machine that does its job.

## Why I Chose Ubuntu Server

There’s no shortage of server OS options — TrueNAS, Proxmox, Debian, Fedora. I went with Ubuntu Server 24.04 LTS because:

- Predictability: I know how it behaves, and that matters when you’re automating.
- Community: most Docker/ZFS guidance assumes Ubuntu/Debian, which saves time.
- LTS stability: same base OS until 2030 without surprise breakage.
- Balance: minimal but polished, giving me control without fights.

I considered TrueNAS for simplicity but didn’t want to hand storage over to a GUI. I wanted full visibility into every mount, dataset, and process. Ubuntu lets me script and automate everything my way.

## Building the ZFS Foundation

I manually set up ZFS-on-root (debootstrap) for transparency. The rpool lives on two mirrored SSDs (`/dev/sda` and `/dev/sdb`), while the `tank` data pool lives on mirrored HDDs for bulk storage.

```bash
zpool status
  pool: rpool
 state: ONLINE
  mirror-0
    sda
    sdb
```

ZFS gives end-to-end integrity, snapshots, compression, and self-healing redundancy. Silent corruption is the enemy — ZFS makes that someone else’s problem.

## Bootloader and Failover

I use ZFSBootMenu as my boot environment, stored at:

```text
/boot/efi/EFI/ZBM/ZFSBootMenu.EFI
```

Both SSDs are bootable mirrors. If one fails, the other continues without manual repair. ZFSBootMenu also provides a small recovery console to roll back snapshots or fix an update from the console — no reinstall, no USB stick.

## Adding a PiKVM for Remote Control

One of the smartest upgrades was a PiKVM — a Raspberry Pi 4 KVM-over-IP connected to the server’s HDMI and USB. Even the best systems eventually need BIOS-level access. If a kernel update freezes or the bootloader breaks, I don’t want to drag out a monitor.

With PiKVM, I can:
- Access the BIOS remotely
- Watch the boot process via HDMI
- Mount ISO images and reinstall from anywhere
- Power-cycle the server via smart plug integration

It’s already saved me — when a Docker update broke the bridge network and SSH went dark, I used the PiKVM console to fix and reboot. The PiKVM UI is published securely through Cloudflare Zero Trust, so no ports are exposed.

## Docker as the Core Platform

The server’s software layer runs through Docker Compose. My philosophy: if it can run in a container, it belongs in one.

I keep everything organized under `/srv/docker/`, one folder per stack:

```text
/srv/docker/
├── pihole/
│   └── docker-compose.yml
├── grafana/
│   └── docker-compose.yml
└── website/
    └── docker-compose.yml
```

Each folder contains a `docker-compose.yml` and a `.env` for credentials/vars.
- `docker compose up -d` brings a stack online
- `docker compose pull && docker compose up -d` updates safely

This modular approach makes maintenance trivial — stop, edit, and rebuild individual stacks without touching the rest.

## GitHub as My Source of Truth

Every configuration lives in a private GitHub repository — from Compose files to Nginx and helper scripts.

Benefits:
- Version control and rollback
- Fast rebuilds from scratch
- A complete change history

Redeploy process is easy: clone the repo and run the init script — minutes later everything matches (stacks, mounts, env vars).

```bash
git add .
git commit -m "tweak: loki retention and grafana dashboards"
git push
```

## Why Docker Compose (not Portainer or Kubernetes)

I’ve used Portainer and Kubernetes, but both are overkill here. I want full control, minimal complexity, and reproducibility.

Compose provides:
- Clear YAML I can read at a glance
- One-command rebuilds
- Git-friendly versioning
- No extra web UIs to babysit

If something fails, I fix it with a text editor — not by clicking through a UI or debugging Helm.

## Problems I Solved Along the Way

- Snap packages slowed boot:
  ```bash
  sudo snap remove lxd core20 core22
  ```
  Replaced with apt packages — faster startup.

- Docker launching before ZFS mounts:
  systemd override to depend on ZFS:
  ```ini
  # /etc/systemd/system/docker.service.d/override.conf
  [Unit]
  Requires=zfs.target
  After=zfs.target
  ```
  ```bash
  sudo systemctl daemon-reload
  sudo systemctl restart docker
  ```

- Persistent data on HDD mirror instead of SSDs:
  ```bash
  zfs create tank/docker
  ```
  Set Docker data-root:
  ```json
  {
    "data-root": "/tank/docker"
  }
  ```

- Remote troubleshooting:
  Before PiKVM, a failed boot meant moving a monitor. Now I can fix anything from a laptop, even off‑site.

## Why This Setup Works

Not the cheapest or flashiest, but it’s reliable, modular, and under my control.

It gives me:
- ZFS for data integrity
- Snapshots for rollback
- Docker for isolation and reproducibility
- GitHub for version tracking
- PiKVM for out-of-band recovery
- UPS protection for graceful shutdowns

It’s the kind of system that quietly runs — and if something does go wrong, I have multiple layers of recovery ready.

## Looking Ahead

Next up: how the network connects everything — VLAN segmentation, Ruckus AP integration, and how the router and server communicate cleanly across subnets.
