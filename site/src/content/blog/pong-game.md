---
title: "Pixel Paddle: A Python Pong Game"
description: "A Python/Pygame learning project with single-player and local two-player modes, collision handling, and retro visuals."
date: 2025-06-29
tags: ["python", "re-learning", "gaming"]
draft: false
---

## Project at a glance

- **Goal:** Rebuild hands-on Python fluency with a small project I could finish.
- **My role:** Built Pixel Paddle with Claude assistance, working through gameplay, configuration, and visual polish.
- **Delivered:** Single-player and local two-player modes, scoring, restart flow, generated audio, and a retro interface.
- **Tradeoff:** Used simple collision math and a configurable computer opponent rather than a physics engine.
- **Status:** Playable learning project; networked multiplayer remains a possible extension.

[Explore the repository](https://github.com/hsivasambu/pong-game)

## Why Pong

Python was the first language I learned at university. After years of spending more time managing technical work than writing code, I wanted a project that would make me use the basics again.

Pong kept the scope manageable while covering input, state, movement, collisions, and feedback. I could see immediately when the code behaved differently from what I intended.

![Pixel Paddle menu](/images/pixel-paddle/menu.jpg)

## The parts that needed attention

**Paddle collisions.** Reversing the ball's direction was only a start. The bounce angle depends on where it hits the paddle. Repositioning it outside the paddle after impact prevents repeated collision detection from trapping it.

**Opponent behavior.** A computer paddle that tracks perfectly is frustrating to play against. A dead zone and a lower movement speed make it beatable without adding a complicated prediction model.

**Sound.** The sound module generates tones rather than loading external audio assets. It also has a fallback path when the optional audio dependencies are unavailable.

**Game state.** Menu, gameplay, scoring, and restart behavior needed clear transitions. Keeping those responsibilities in separate modules made it easier to change one part without losing track of the others.

![Pixel Paddle gameplay](/images/pixel-paddle/gameplay.jpg)

## What I learned

The most useful part was finishing the whole flow: launch, play, win or lose, restart, and return to the menu. Small defects in those transitions were more noticeable than missing visual effects.

The project gave me a practical way to refresh Python and a reminder to keep the next deliverable small enough to test through to completion.

![Pixel Paddle winner screen](/images/pixel-paddle/winner.jpg)
