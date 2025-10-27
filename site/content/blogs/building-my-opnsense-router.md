---
title: "Building My OPNsense Router"
date: 2025-07-05
tags: ["network", "opnsense", "router", "zfs"]
summary: "Replacing the AT&T gateway with a custom OPNsense router for full control, reliability, and visibility."
draft: false
---
When I started rebuilding my home network this summer, one of the first things I wanted to fix was the router situation. The AT&T gateway worked fine for basic internet access, but it was locked down, unpredictable, and didn’t give me anywhere near the control or visibility I wanted. So I built my own router — running OPNsense on a Dell OptiPlex Micro with mirrored drives and ZFS for reliability.

Hardware & OS Setup
The hardware is modest but solid:

Dell OptiPlex Micro PC

Two NVMe/SATA drives in a ZFS mirror

Intel dual-NIC setup

APC Smart-UPS connected via USB for power event handling

I installed OPNsense manually with ZFS-on-root so the OS itself benefits from data integrity and snapshot capabilities. I mirrored both drives (/dev/nvme0n1 and /dev/sda) using the ZFS mirror option in the installer.
After installation, I verified the pool health with:

bash
Copy code
zpool status
I also set up ZED alerts so I’d get notified if a drive failed:

bash
Copy code
/etc/zfs/zed.d/zed.rc
ZED_EMAIL_ADDR="myemail@example.com"
ZED_NOTIFY_VERBOSE=1
It’s overkill for a router, but it’s nice to know I can lose a drive and keep running.

Interface Naming & VLANs
I renamed the physical interfaces for clarity:

wan → external (connected to ONT)

lan → internal (trunk to managed switch)

Then I created VLANs directly on the LAN interface:

VLAN 10 – Main

VLAN 20 – Guest

VLAN 30 – IoT

Each VLAN gets its own subnet, DHCP scope, and firewall rules. The managed switch (a Netgear GS105E-v2) handles tagging, and my Ruckus R610 AP (static IP 10.0.0.5) broadcasts the corresponding SSIDs.

This lets me completely isolate devices like cameras and smart plugs from the rest of the network, while still keeping everything manageable from one place.

UPS & Power Handling
The router is plugged into my APC Smart-UPS, which connects via USB. I configured OPNsense’s NUT service to gracefully shut down if power runs low and then auto-boot when power returns.

This matters because I’m also using ZFS — an unclean power loss could corrupt datasets. Between mirrored drives and a monitored UPS, I’ve eliminated almost all single points of failure.

ZFS Boot & Redundancy
The bootloader path for OPNsense on this box is:

swift
Copy code
/boot/efi/EFI/ZBM/ZFSBootMenu.EFI
ZFSBootMenu gives me a nice recovery layer in case something breaks during an update. It’s minimal, stable, and easy to replicate if I ever rebuild.

Why It Matters
This setup turned my router from a black box into a reliable, observable part of the network. I can SSH in, snapshot configurations, back them up, and even graph its performance alongside the rest of my infrastructure.

It’s also future-proof. I can add more VLANs, connect secondary WANs, or integrate failover later — all without replacing hardware or fighting firmware limits.

The best part is peace of mind: if a drive dies, power goes out, or the gateway reboots, everything just comes back up clean. For a homelab, that’s the difference between “good enough” and “rock solid.”

Next up: setting up the main server with ZFS, Docker Compose, and GitHub for configuration control.

