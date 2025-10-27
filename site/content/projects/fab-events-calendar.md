---
title: "FAB Events Calendar"
description: "Dockerized Python automation that scrapes FAB TCG events, publishes a calendar, and posts Discord alerts with health checks."
tags: ["python", "docker", "automation"]
image: "/images/projects/fab-events.svg"
_build:
  list: false
  render: true
date: 2025-09-10
---

Overview

A production-grade automation that scrapes Flesh and Blood TCG events, syncs them to Google Calendar/iCal, and sends Discord notifications.
The service runs in Docker with a simple schedule and weekly health checks for uptime.

Highlights

- Python scraper and normalizer for event data
- Calendar publishing (Google and iCal)
- Discord alerting, plus weekly health checks
- Containerized for easy deploys and updates

Read more

- [FAB Calendar Automation Project: Automating the Flesh and Blood Event Feed](/blogs/fab-calendar-automation-project/)

Links

- GitHub: https://github.com/chaco-win/fab-events-sync
- Live site: https://fabevents.chaco.dev
