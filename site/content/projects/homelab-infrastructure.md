---
title: "Homelab Infrastructure"
description: "Ubuntu + ZFS mirror, Pi-hole/Unbound, PiKVM, OPNsense VLANs, automated backups, Cloudflare Tunnel."
tags: ["homelab", "zfs", "opnsense", "networking"]
image: "/images/projects/homelab.svg"
_build:
  list: false
  render: true
date: 2025-07-05
---

Overview

Your backbone project — the full stack of your home server, router, and network.
Ubuntu + ZFS, Pi-hole/Unbound, PiKVM, OPNsense VLAN segmentation, automated backups, and off-site replication.

Highlights

- ZFS mirror for reliability, frequent snapshots, and off-site replication
- OPNsense routing, VLANs, and clean subnet layout
- Pi-hole + Unbound with DNSSEC and split-horizon where needed
- Cloudflare Tunnel for zero-exposed inbound ports
- Automated backups and monitoring

Related blog posts

- [Building My OPNsense Router](/blogs/building-my-opnsense-router/)
- [Building My Home Server: ZFS, Docker, and GitHub Automation](/blogs/building-my-home-server/)
- [Building My Network: VLANs, Segmentation, and Wi-Fi Integration](/blogs/building-my-network/)
- [Redundancy by Design: Local Snapshots, Off-Site Backups, and Cloud Failsafes](/blogs/redundancy-by-design/)
