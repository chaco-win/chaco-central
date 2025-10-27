---
title: "Building and Hosting My Website: Hugo, Docker, and Cloudflare Integration"
date: 2025-09-20
tags: ["homelab", "docker", "hugo", "cloudflare", "cloudflared", "caddy"]
summary: "How I built and hosted www.chaco.dev using Hugo, Docker Compose, and Cloudflare Tunnel — a fast, secure, and self‑contained setup with zero exposed ports."
draft: false
---

After getting my network, server, and automation projects in place, I wanted a clean way to showcase what I had built — somewhere to document my homelab, projects, and technical work without relying on platforms I do not control.

That became www.chaco.dev — a static site built with Hugo, hosted on my own server, and served securely through a Cloudflare Tunnel.

## Why Build My Own Site

I could have used WordPress or a hosted builder, but that missed the point of everything I have been doing. I wanted something:
- Lightweight — no database, no PHP, no maintenance headaches
- Version‑controlled — changes tracked on GitHub
- Self‑hosted — served directly from my infrastructure
- Secure — no open ports, minimal attack surface

Hugo and Docker made that combination possible. The site loads in milliseconds, builds quickly, and costs me nothing but disk space.

## The Stack

The site runs as a small, self‑contained Docker Compose stack:

```
/srv/docker/mywebsite/
- docker-compose.yml
- Caddyfile
- site/
  - config.toml
  - public/
- .env
```

Each container does one thing well:
- Hugo — builds the static site from Markdown
- Caddy — serves the built site (headers, caching, local TLS)
- Cloudflared — connects the server to Cloudflare securely through a tunnel

The source code lives on GitHub under the same domain branding.

## Docker Compose Setup

I keep the configuration minimal, readable, and portable:

```yaml
services:
  caddy:
    image: caddy:latest
    container_name: caddy
    volumes:
      - ./site/public:/usr/share/caddy
      - ./Caddyfile:/etc/caddy/Caddyfile
    networks:
      - web_pub
    restart: unless-stopped

  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    environment:
      - TUNNEL_TOKEN=${TUNNEL_TOKEN}
    networks:
      - web_pub
    restart: unless-stopped

networks:
  web_pub:
    driver: bridge
```

No ports are exposed. Traffic flows through Cloudflare’s tunnel into the Caddy container — the public internet never touches my network directly.

## Hugo: Markdown and Simplicity

All posts on www.chaco.dev — including this homelab series — are written in Markdown.

Hugo turns each .md file into static HTML, with front matter metadata at the top (title, date, tags). That means no CMS, no plugin mess, and fewer security risks.

The layout uses a minimal Hugo theme that I customized to match my branding — teal accents, clean typography, and plenty of whitespace.

I do not use trackers, ads, or heavy analytics — just clean, static content that renders fast.

## GitHub and Deployment

The site’s Git repo lives on GitHub, where each commit is tracked and versioned. When I write or edit a post:
1. Commit to GitHub
2. Pull the latest version onto my server
3. Run `hugo` to rebuild the static files
4. Caddy serves the updated content from the mounted directory

Eventually, I will automate that rebuild via a webhook or cron so I can just push to GitHub and have it publish automatically.

## Cloudflare Tunnel and Domain Setup

Cloudflare Tunnel does the heavy lifting. Instead of exposing ports 80/443, I connect to Cloudflare’s network from the inside using cloudflared.

That gives me:
- Automatic SSL through Cloudflare
- DDoS protection and caching
- Zero firewall holes

DNS for www.chaco.dev points to the tunnel, not my home IP. Even if my server IP changes, the tunnel keeps routing traffic safely and transparently.

## Why I Built It This Way

This setup fits my goals:
- Private — no inbound traffic and minimal attack surface
- Fast — static pages, cached at Cloudflare’s edge
- Controlled — everything lives in Git, served from Docker
- Portable — deploy the same stack anywhere with `docker compose up -d`

It is simpler than the alternatives and more secure at the same time.

## Challenges Solved

- Docker networking — Caddy and Cloudflared share a network for internal routing
- Path confusion — Hugo builds to /public, Caddy expects /usr/share/caddy (fixed via correct mount)
- SSL headaches — Cloudflare handles certificates end‑to‑end
- Cache updates — small TTLs and `hugo --minify` keep updates quick

## Future Plans

- Add a privacy‑friendly analytics layer (Plausible or self‑hosted Umami)
- Set up RSS feeds and auto‑deploy from GitHub Actions
- Mirror the site to a small VPS or object storage for redundancy
- Continue writing short blog notes for project updates

## Final Thoughts

I built www.chaco.dev to be simple, self‑contained, and reliable. It runs quietly in Docker, served through Cloudflare, and rebuilt from Markdown whenever I want. No ads. No clutter. Just my work, on my terms.
