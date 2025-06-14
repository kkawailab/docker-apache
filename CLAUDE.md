# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a simple Docker-based Apache web server project. The repository contains a Dockerfile that creates an Ubuntu-based container running Apache2.

## Commands

### Building the Docker image
```bash
docker build -t apache-simple .
```

### Running the container
```bash
docker run -d -p 8080:80 apache-simple
```

### Stopping and removing the container
```bash
docker ps  # Find container ID
docker stop <container_id>
docker rm <container_id>
```

## Architecture

The project consists of:
- `Dockerfile`: Creates an Ubuntu 24.04 container with Apache2 installed
  - Sets timezone to Asia/Tokyo
  - Exposes port 80
  - Expects an `index.html` file to be copied to `/var/www/html/`
  - Runs Apache in foreground mode

## Important Notes

1. The Dockerfile expects an `index.html` file in the same directory, which needs to be created before building the image
2. The Dockerfile contains Japanese comments
3. Apache runs on port 80 inside the container, which should be mapped to a host port when running