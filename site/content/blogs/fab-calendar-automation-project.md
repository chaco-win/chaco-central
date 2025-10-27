---
title: "FAB Calendar Automation Project: Automating the Flesh and Blood Event Feed"
date: 2025-09-10
tags: ["homelab", "automation", "docker", "github", "fabtcg", "discord"]
summary: "Building a Dockerized automation that scrapes Flesh and Blood events, syncs them to a public calendar, and powers a Discord bot with real-time updates and customizable reminders."
draft: false
---

After getting my network and server dialed in, I wanted to put that stability to work doing something useful — something that solved a real problem I deal with every week.

For anyone in the Flesh and Blood TCG community, the official event site lists everything, but it isn’t designed for quick reference or notifications. I wanted one unified, automatically updating calendar — something I could subscribe to on my phone or share with my playgroup.

GitHub: [github.com/chaco-win/fab-events-sync](https://github.com/chaco-win/fab-events-sync)  
Live calendar: [fabevents.chaco.dev](https://fabevents.chaco.dev)
## Why This Project

- One place to see competitive events without digging through pages.
- Shareable, phone-friendly calendar that updates itself.
- Discord notifications so groups stay informed automatically.
- Built to run unattended: containers, health checks, and logs.


## The Goal

Create a fully automated system that:
1. Scrapes new Flesh and Blood events from FABTCG.com
2. Parses and normalizes event data (name, date, location, format)
3. Publishes them to a shared calendar and web frontend
4. Notifies users through Discord when new events are added
5. Monitors itself and reports any issues automatically

Containerized, version-controlled, and built to survive without babysitting.

## The Stack

A small Docker Compose stack on my home server:

```text
/srv/docker/fab-calendar/
+-- docker-compose.yml
+-- scraper/
¦   +-- main.py
¦   +-- requirements.txt
+-- logs/
```

The scraper handles scraping, parsing, and syncing via the Google Calendar API. It’s lightweight, stateless, and auto-restarts if something fails.

```yaml
services:
  fab-calendar:
    build: ./scraper
    volumes:
      - ./logs:/logs
    environment:
      - GOOGLE_CREDENTIALS_JSON=/config/creds.json
      - DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
    restart: always
```

## How It Works

1. Scraping: Pulls FABTCG\'s event listings and parses them into structured JSON. Filters by format (ProQuest, Battle Hardened, Nationals) and skips duplicates.
2. Calendar Sync: Authenticates with a Google service account and updates the shared public calendar at fabevents.chaco.dev.
3. Discord Notifications: Posts a formatted message to Discord via webhook or bot token when new events are detected.
4. Health Monitoring: Logs to /logs/fab-calendar.log and records status for weekly health checks.

## Weekly Health Checks

Every Sunday morning a separate process verifies:
- The scraper ran successfully within the past week
- The last calendar update timestamp is valid
- No repeated errors in the logs

If anything fails, a Discord notification fires automatically.

```text
[HealthCheck] Last run: 2025-09-07 06:00 UTC
[HealthCheck] Calendar updated successfully (45 total events)
[HealthCheck] No errors detected
```

## Discord Integration and Notifications

When events are updated:
```text
FAB Calendar Updated
3 new events found:
- ProQuest: Dallas, TX
- Battle Hardened: Sydney, AUS
- Nationals: New Zealand
```

If the scraper fails:
```text
FAB Calendar ERROR
Traceback: 'NoneType' object has no attribute 'find'
```

## Future Plans: Public Discord Bot

Next phase: a public Discord bot anyone can invite. It’ll use the same backend but expose slash commands.

Planned features:
- /fab upcoming — list upcoming events by region or format
- /fab subscribe — subscribe to notifications for types/regions
- /fab remind — automated reminders (e.g., Monday before)
- /fab optout — unsubscribe from categories
- /fab health — scraper uptime and last update status

## Challenges and Lessons Learned

- Cloudflare rate limits: randomized delays, caching, and backoff to avoid being flagged
- Timezones: everything converted to UTC to prevent offsets
- Token management: automatic key rotation for Google API tokens
- Webhook spam: deduplicate by event ID

## Why It Works in My Setup

- Hosted in Docker on mirrored ZFS for redundancy
- Uses Pi-hole for DNS and logging visibility
- Exposed securely through Cloudflare Tunnel — no open ports
- Snapshotted and backed up weekly

It’s stable, isolated, and low-maintenance — exactly what I wanted.

## Looking Ahead

Source: [github.com/chaco-win/fab-events-sync](https://github.com/chaco-win/fab-events-sync)  
Calendar: [fabevents.chaco.dev](https://fabevents.chaco.dev)

Next steps:
- Launch the public Discord bot
- Add customizable reminders for local stores/leagues
- Build a small dashboard for curation and feedback
