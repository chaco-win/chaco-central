---
title: "TCG Resale & Automation"
description: "Independent trading card resale business on TCGPlayer with custom VBA tooling for dynamic repricing based on market data, inventory depth, sales velocity, and rarity-based markups."
tags: ["vba", "excel", "automation", "business"]
image: "/images/projects/tcg-resale.svg"
_build:
  list: false
  render: true
date: 2025-10-01
---

## Overview

An independent trading card resale business operating primarily on TCGPlayer, with a custom Excel VBA automation layer built to handle the parts that don't scale manually — specifically repricing.

The core of the tooling is a dynamic repricing engine that takes multiple inputs and outputs updated prices across the inventory without manual calculation.

## The Repricing Engine

Manually keeping prices competitive across a large inventory isn't realistic. The VBA tool pulls together several factors and calculates a target price for each card:

- **Current low** — what the market floor looks like right now on TCGPlayer
- **Market price** — the rolling average buyers are actually paying
- **Quantity on hand** — more copies = more aggressive pricing; low stock = less pressure to undercut
- **Sales velocity** — time since last sale; stale listings get nudged down, fast movers get room to hold price
- **Cost basis & rarity** — floor prices and markup percentages are tiered by rarity and what was paid, so high-value or expensive-to-source cards are protected from accidental underpricing
- **Staple floors** — certain high-demand cards get a hard minimum regardless of market conditions

The result: one run of the tool and the entire inventory reprices itself based on current conditions rather than gut feel or manual comparisons.

## Inventory Management

Beyond pricing, the tooling tracks:

- Stock levels and restock needs
- Excess inventory flags for cards that have sat too long
- Cost basis per card for margin visibility
- Order fulfillment status

## Why VBA

The business already lived in Excel. VBA let me automate directly within that workflow without adding external tools, APIs, or dependencies. The entire system is self-contained — open the file, run the tool, prices are updated.

## Platform

Sold exclusively on **TCGPlayer**. Inventory spans multiple TCG titles, primarily Flesh and Blood.
