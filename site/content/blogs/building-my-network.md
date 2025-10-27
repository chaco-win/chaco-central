---
title: "Building My Network: VLANs, Segmentation, and Wi‑Fi Integration"
date: 2025-08-09
tags: ["homelab", "networking", "vlan", "opnsense", "ruckus", "grafana", "automation"]
summary: "Designing a segmented home network with OPNsense, a managed switch, and a Ruckus access point — built mostly from spare parts and configured for automation, visibility, and resilience."
draft: false
---

By August, the network side of my homelab was finally starting to take shape.
Once the router and server were solid, I turned my focus to the rest of the network — specifically, how to make it organized, resilient, and fully under my control.

I wanted professional‑level segmentation and reliability without spending enterprise‑level money. Like most of this lab, I built it almost entirely from hardware I already had, plus one excellent deal from eBay.

---

## Hardware: Built from What I Had

This network was assembled on a tight budget but with deliberate choices:

- Router: my custom OPNsense box on a Dell OptiPlex Micro
- Switch: Netgear GS105E‑v2 — already in my parts bin; supports VLAN tagging
- Access Point: Ruckus R610 I picked up cheap on eBay (about a third of retail)

That Ruckus AP was the MVP. It’s enterprise‑grade: rock‑solid firmware, excellent range, multiple SSIDs, and VLAN tagging that just works.

The total out‑of‑pocket cost was under $100 — and it performs like something ten times that.

---

## Hardwiring and AP Placement

To get the most out of the Ruckus, I didn’t just plug it in on a shelf — I ran Cat5e through the wall and ceiling to mount it in a central spot in the house.
That small bit of effort made a huge difference: consistent coverage, faster speeds, and fewer dead zones.

Running cable through drywall isn’t glamorous, but it’s worth it. A single clean run from the switch to the AP keeps the setup tidy and eliminates the need for patch cables across the room.

---

## VLAN Segmentation: Organized from the Ground Up

Here’s how I divided it up in OPNsense:

| VLAN | Purpose | Subnet      | Notes                           |
|-----:|---------|-------------|---------------------------------|
|   10 | Main    | 10.0.0.0/24 | PCs, NAS, management            |
|   20 | Guest   | 10.0.20.0/24| Old SSID reused for guests      |
|   30 | IoT     | 10.0.30.0/24| Smart plugs, cameras, TVs, etc. |

Each VLAN has its own DHCP range and firewall rules.
- Main (10): full LAN access; uses Pi‑hole for DNS filtering and logging
- Guest (20): internet‑only; uses standard DNS (1.1.1.1 / 8.8.8.8)
- IoT (30): highly restricted — devices can only talk to Pi‑hole and the internet, not the rest of my LAN

---

## SSID Design: Preventing Chaos and Staying Organized

Switching SSIDs can brick half the devices in a house — especially smart TVs and speakers. To avoid that, I reused the old SSID name for the Guest VLAN (VLAN 20). Everything reconnected automatically, but behind the scenes it’s isolated from my main lab.

Then I created:
- A private SSID for me that uses VLAN 10 and routes through Pi‑hole
- A dedicated IoT SSID tied to VLAN 30 for smart plugs, lights, and other devices

This kept the peace and gave me total DNS and traffic control. I can see every domain request from my devices, while guests stay completely sandboxed.

---

## Configuring the VLANs

In OPNsense, VLAN setup was simple once the tagging was right:

```text
Interfaces → Other Types → VLAN
Parent Interface: lan
Tags: 10, 20, 30
```

The Netgear GS105E‑v2 trunk port carries all three VLANs to the Ruckus AP, while the other ports are untagged for their assigned networks.

On the Ruckus, I mapped:

- SSID "Main"  → VLAN 10
- SSID "Guest" → VLAN 20
- SSID "IoT"   → VLAN 30

Once the AP rebooted, DHCP leases showed up under the right scopes, and isolation worked as planned.

---

## Why It Matters

Consumer routers blend everything together. That’s fine for small homes, but once you add IoT gear, servers, and lab systems, it becomes a liability.

This setup gives me:
- True isolation between sensitive and insecure devices
- Custom DNS control per VLAN
- Network visibility through Grafana
- Flexibility for future expansion (VPN‑only VLANs or lab test zones)

It’s the same design philosophy you’d see in a small business network — just scaled to a home.

---

## Real Problems and How I Solved Them

1) Ruckus VLAN quirks: by default the AP dumped everything on VLAN 1. I disabled the default untagged WLAN and explicitly bound each SSID to its VLAN.

2) Netgear tagging confusion: the GS105E’s UI isn’t intuitive. I labeled ports, tested one VLAN at a time, and verified with `ping`/`ipconfig` to ensure the right gateway/subnet.

3) IoT connectivity: some devices broke when fully isolated. I allowed only UDP/53 and HTTPS to Pi‑hole and external DNS. Everything stabilized.

---

## UPS, Power, and Smart Plug Automation

The router, switch, and Ruckus AP are all on an APC Smart‑UPS, with smart plugs on the switch and AP. If either hangs (rare), I can toggle power remotely without touching the router or server.

Looking ahead, I plan to automate full network recovery using those plugs:
- A triggered script that power‑cycles the AP and switch in sequence after outages
- Integration with NUT so services restart automatically once power stabilizes
- Future Grafana alerts that trigger plug actions if latency spikes or devices stop responding

Goal: the network should bring itself back online — no manual resets.

---

## Monitoring and Visibility

I feed data from OPNsense and the router into Grafana, using Prometheus and Loki containers on the server. I track:
- Interface throughput (per VLAN)
- Wi‑Fi signal and client counts
- Ping and DNS latency
- Device uptime and power events

It’s not over‑engineering — it’s about knowing what’s happening at all times. If something starts failing, I see it before anyone notices.

---

## Why I Built It This Way

This network isn’t flashy — it’s deliberate. Every design choice has a reason:
- Running Cat5e through the ceiling gave me clean, central coverage
- Reusing the old SSID prevented a household meltdown
- VLANs gave me control and separation
- Cheap enterprise hardware outperformed consumer options
- Automation and UPS integration keep it resilient

I don’t want to manage problems — I want to engineer them out entirely. This setup does exactly that.

---

## Next Up

Next, I’ll cover the FAB Calendar Project — a bot that scrapes Flesh and Blood events and automatically updates a shared calendar through Docker and GitHub automation. That’s where the network and the server finally start working together as one cohesive system.

