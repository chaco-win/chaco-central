---
title: "Building My OPNsense Router"
date: 2025-07-05
tags: ["network", "opnsense", "router", "zfs"]
summary: "Replacing the AT&T gateway with a custom OPNsense router for full control, reliability, and visibility."
draft: false
---

When I rebuilt my network this summer, the stock ISP gateway was the first thing to go. It worked for basic internet, but it was locked down and offered little visibility. I replaced it with a small, reliable box running OPNsense with mirrored storage and ZFS so I can observe, back up, and recover cleanly.

## Hardware & OS Setup

The hardware is modest but solid:

- **Dell OptiPlex Micro PC**
- **Two NVMe/SATA drives** in a ZFS mirror
- **Intel dual‑NIC** setup
- **APC Smart‑UPS** connected via USB for power event handling

I installed OPNsense manually with ZFS‑on‑root so the OS benefits from ZFS integrity and snapshots. I mirrored both drives (`/dev/nvme0n1` and `/dev/sda`) using the ZFS mirror option in the installer.

After installation, I verified the pool health with:

```bash
zpool status
```

I also enabled ZED alerts so I get notified if a drive fails:

```bash
# /etc/zfs/zed.d/zed.rc
ZED_EMAIL_ADDR="myemail@example.com"
ZED_NOTIFY_VERBOSE=1
```

It’s more than you strictly need for a router, but it means I can lose a drive and keep running.

## Interface Naming & VLANs

I renamed the physical interfaces for clarity:

- `wan` → external (connected to ONT)
- `lan` → internal (trunk to managed switch)

Then I created VLANs on the LAN trunk:

- **VLAN 10 – Main**
- **VLAN 20 – Guest**
- **VLAN 30 – IoT**

Each VLAN has its own subnet, DHCP scope, and firewall rules. The managed switch (Netgear GS105E‑v2) handles tagging, and the Ruckus R610 AP (static `10.0.0.5`) broadcasts the corresponding SSIDs.

## UPS & Power Handling

The router is on an APC Smart‑UPS via USB. OPNsense’s NUT service is configured to shut down cleanly if power runs low and auto‑boot when power returns. Combined with ZFS, this avoids unclean power loss and reduces the chance of data corruption.

## ZFS Boot & Redundancy

The bootloader path on this box is:

```text
/boot/efi/EFI/ZBM/ZFSBootMenu.EFI
```

ZFSBootMenu gives me a simple recovery layer if an update goes sideways. It’s minimal, stable, and easy to replicate.

## Why OPNsense

- Clean, modern UI with frequent releases and an active plugin ecosystem.
- First‑class features out of the box: WireGuard/OpenVPN, Unbound DNS, Suricata IDS/IPS, VLANs, traffic shaper/QoS.
- Visibility and troubleshooting: live firewall states, packet capture, searchable logs, built‑in health graphs.
- Automation‑friendly: backup/restore, API hooks, and ACME/Let’s Encrypt integration.

Alternatives considered
- pfSense: similar capability. I preferred OPNsense’s release cadence and plugin flexibility.
- Ubiquiti (USG/UXG/UDM): great UI/APs, but fewer advanced firewall features and limited on‑box control.
- MikroTik: powerful, but steeper learning curve for my goals.
- Consumer routers: inconsistent updates, limited VLAN/IDS, and poor observability.

## Why a ZFS Mirror (Redundancy)

- Fault tolerance: survive a single disk failure with no downtime.
- Data integrity: end‑to‑end checksums detect/correct bit rot; scrubs keep pools healthy.
- Snapshots/rollbacks: snapshot configs and quickly revert after an update or change.
- Fast resilver: mirrors rebuild faster than parity RAID for small OS pools.
- Works well with ZFSBootMenu for safe updates and quick recovery.

Mirror vs. RAIDZ1
- Router workload is small random I/O; a 2‑disk mirror is simpler and quicker to resilver.
- OS + configs are tiny; parity adds complexity without benefit here.

Operational bits

```bash
# health
zpool status

# monthly scrub (cron)
zpool scrub zroot
```

```bash
# /etc/zfs/zed.d/zed.rc (email alerts)
ZED_EMAIL_ADDR="myemail@example.com"
ZED_NOTIFY_VERBOSE=1
```

## Hardware Choices: Dual NIC via M.2 adapter

The OptiPlex Micro only exposes one onboard Ethernet port. To meet the WAN/LAN split without USB dongles, I added a low‑profile M.2‑to‑NIC adapter:

- Form factor: keeps everything inside the case; no dangling USB.
- Throughput and drivers: Intel‑based NIC presents reliable performance and native driver support in BSD.
- Power/thermals: minimal draw; stays within the chassis thermal envelope.

This let me dedicate `wan` to the ONT and `lan` to the trunked switch, with VLANs layered on the LAN side.

## Results

This turned the router from a black box into an observable, dependable part of the network. I can SSH in, snapshot and back up configs, and graph performance alongside the rest of the environment. If a drive dies, power blips, or the gateway reboots, it comes back up clean.

Next up: finishing the main server build with ZFS, Docker Compose, and GitHub‑based configuration.
