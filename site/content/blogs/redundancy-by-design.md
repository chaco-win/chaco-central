---
title: "Redundancy by Design: Local Snapshots, Off-Site Backups, and Cloud Failsafes"
date: 2025-10-15
tags: ["homelab", "zfs", "backups", "sanoid", "syncoid", "cloudflare", "backblaze"]
summary: "Designing a resilient backup strategy built on ZFS snapshots, off-site replication to parents-nas, and a future cloud failsafe tier using Backblaze."
draft: false
---

Data loss isn’t an “if” problem — it’s a “when.”
After finishing my router and server builds, it was time to tackle the part that actually keeps everything alive when things go sideways: backups.

This post breaks down how I built a layered backup system — local snapshots, off-site replication to my parents’ NAS, and a future cloud tier for total disaster protection.

## Local Backups: ZFS + Automation

Everything starts with ZFS. My main server runs mirrored SSDs for the `rpool` (boot) and a mirrored HDD pool called `tank` for storage. Each major dataset has a clear purpose:

| Dataset       | Purpose                            |
|---------------|------------------------------------|
| `rpool`       | Boot pool and system datasets      |
| `tank/docker` | Persistent Docker volumes          |
| `tank/media`  | Media and archived files           |
| `tank/backups`| Local daily backups and exports    |
| `tank/config` | Config files, Compose stacks, secrets |

To manage all of this, I use Sanoid. It handles:
- Automatic hourly, daily, and weekly snapshots
- Smart retention policies (keep short‑term frequent, prune old automatically)
- Integration with Syncoid for replication jobs

Local snapshots give me fast rollback capability and let me recover a single container or config without touching off‑site copies.

Every night, Syncoid replicates all the above datasets to a local backup drive — an older HDD dedicated solely to cold storage.

## Router Backups

My OPNsense router also runs on ZFS, and it’s part of the plan.
The router’s pool is included in nightly Syncoid jobs that replicate its configuration and logs to my main server.

This means if the router’s SSD dies, I can rebuild it, restore its pool, and have everything — from VLAN setups to firewall rules — back exactly as it was.

It’s overkill for some people. For me, it’s peace of mind.

## Off-Site Backups: parents‑nas

The next layer lives outside my house — on a small ZFS system at my parents’ place, called `parents-nas`.

That system pulls double duty:
- It’s a file server for them (photos, documents, shared folders)
- It’s also my off‑site backup target for critical datasets

Replication is handled automatically through Syncoid, which sends encrypted ZFS streams over SSH. The connection itself runs inside a Cloudflare Tunnel, so there are no open ports exposed to the internet.

### Two‑Way Protection

The coolest part: it’s mutual.
While my server replicates important datasets (`tank/config`, `tank/backups`, etc.) to `parents-nas`, it also backs up their data back to my local `tank` pool.

That way, both locations can survive independent hardware failures. If my house burns down, their files are safe. If their system dies, my local server still has their copies.

Replication runs nightly using incremental sends so bandwidth stays reasonable. Each job is validated by Sanoid health checks and a Grafana alert if replication fails or gets stale.

## Cloud Failsafe: Backblaze B2

The final tier will be the “all‑else‑fails” button.

Eventually, I’ll add a Backblaze B2 remote backup for true off‑site redundancy. This will only hold a small, compressed, encrypted subset of my data:
- Docker Compose files and configs
- Critical personal documents
- PiKVM images and scripts
- Snapshot metadata

The idea is simple: if both my local system and `parents-nas` die, I still have a secure cloud copy I can restore from anywhere. It’s cheap, isolated, and it closes the loop on disaster recovery.

## Automation and Monitoring

Backups are worthless if they silently fail.
That’s why I built everything around Sanoid and Syncoid, backed by Grafana for visibility.

- Sanoid runs scheduled snapshot jobs, pruning and validating them
- Syncoid handles replication for each dataset and logs transfer stats
- Prometheus exporters feed Grafana dashboards showing snapshot age, replication lag, and available space
- Discord notifications fire if something stops syncing or snapshots get too old

Once a week, I manually verify restores by mounting a snapshot or using `zfs rollback` on a test container just to confirm the chain works.

## Challenges and Solutions

- Bandwidth: nightly replication can choke if large files change. Incremental sends and bandwidth throttling keep it under control
- Encryption keys: SSH keys and ZFS encryption keys are managed separately; both systems hold only what they need
- Permissions: sharing the NAS with my parents meant strict separation — their data lives in a dedicated pool (`family`), my backups in another (`remote-backups`)
- Scheduling: staggering jobs keeps the router, main server, and parents‑nas from overlapping replication windows

## Future Plans

- Finish integrating the Backblaze cloud tier
- Add periodic restore‑verification scripts
- Build a Grafana dashboard showing snapshot health for all systems
- Experiment with ZFS send deduplication for faster off‑site sync
- Automate replication job summaries posted to Discord weekly

### Closing Thoughts

This setup took time, but it’s exactly what I wanted — redundancy that runs quietly in the background and survives nearly anything.

If my router dies, I can restore it.
If my drives die, I can roll back.
If my house dies, I still have copies at my parents’.
And if everything dies — Backblaze has me covered.

That’s not paranoia. That’s preparation.
