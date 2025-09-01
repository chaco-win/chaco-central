---
title: "Homelab Overview — Ubuntu + ZFS, Pi‑hole/Unbound, PiKVM, OPNsense"
date: 2025-09-01
tags: ["homelab", "zfs", "dns", "opnsense", "backup", "cloudflare-tunnel"]
draft: false
---

Infrastructure

- Ubuntu server with ZFS mirror for OS and RAID‑Z1 for bulk storage
- VLANs on OPNsense; DHCP/DNS split across Pi‑hole + Unbound
- PiKVM for out‑of‑band access
- Backup strategy with offsite replication
- Cloudflare Tunnel for ingress (no host ports exposed)

Goals

- Reproducibility, documentation, and clean rollback paths
- Fast, cache‑friendly static site delivery (Hugo + Nginx)

What’s Next

- Post specific configs: ZFS layout, Pi‑hole macvlan/bridge, Cloudflare Tunnel compose

