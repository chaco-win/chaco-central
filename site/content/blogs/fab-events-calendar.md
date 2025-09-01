---
title: "FAB Events Calendar — Dockerized Scraper to Google Calendar/iCal"
date: 2025-09-01
tags: ["python", "docker", "automation", "cron", "google-calendar"]
draft: false
---

Overview

FAB Events Calendar is a Python app running in Docker that scrapes event websites on a schedule and syncs them to Google Calendar/iCal. It ties into my Hugo hub site, runs daily health checks (cron), and posts Discord notifications for visibility.

Highlights

- Containerized Python scraper with configurable sources
- Writes to Google Calendar/iCal with idempotent updates
- Daily cron + Discord webhooks for status
- Clean logs and simple configuration for new sources

Stack

- Python requests/BeautifulSoup
- Docker + Compose for packaging and scheduling
- Google Calendar API + iCal feed
- Discord webhook for notifications

Notes

- I’ll publish a redacted config and a sample source adapter in a follow-up post.

