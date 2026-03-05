# Plan: Write README for RunPod Template

## Context
The project is a RunPod pod template that bundles Ollama + Open WebUI into a single Docker image. The README needs to document the template for anyone deploying it on RunPod — covering what it does, how to set it up, and what to expect on first boot.

## Target file
`C:\Users\jamie\Downloads\runpod\README.md` (new file)

## Structure
1. **Title + one-line description**
2. **Stack** — Ollama, Open WebUI, base image
3. **Designed for** — RTX PRO 6000 / 96 GB VRAM specs
4. **Quickstart** — RunPod template settings (image URL, ports, disk, env vars)
5. **First boot** — model pull behaviour, how to monitor it, subsequent boots are instant
6. **Services** — port table (8080 WebUI, 11434 API)
7. **Environment variables** — table of supported vars with defaults
8. **Volume layout** — what lives where

## Constraints
- Short and scannable (no walls of text)
- Informative but not exhaustive
- Plain Markdown, no emojis