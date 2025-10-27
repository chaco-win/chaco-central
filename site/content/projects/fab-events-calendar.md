---
title: "FAB Events Calendar"
description: "Dockerized Python automation that scrapes FAB TCG events, publishes a calendar, and posts Discord alerts with health checks."
tags: ["python", "docker", "automation"]
image: "/images/projects/fab-events.svg"
_build:
  list: false
  render: true
---

Overview

A production‑grade automation that scrapes Flesh and Blood TCG events, syncs them to Google Calendar/iCal, and sends Discord notifications.
The service runs in Docker, with a simple schedule and weekly health checks for uptime.

Highlights

- Python scraper and normalizer for event data
- Calendar publishing (Google and iCal)
- Discord alerting, plus weekly “still alive” checks
- Containerized for easy deploys and updates

Read more

- Project write‑up: /blogs/fab-calendar-automation-project/
