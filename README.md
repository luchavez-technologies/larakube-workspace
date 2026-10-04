# LaraKube workspace images

Container images for LaraKube CLI workspaces: a language toolchain, git and a browser editor
([code-server](https://github.com/coder/code-server), MIT), run on a server you own.

| Image | Frameworks |
| --- | --- |
| `ghcr.io/luchavez-technologies/larakube-workspace-images/php:<version>` | Laravel, Statamic, WordPress. Built on [Server Side Up](https://serversideup.net/open-source/docker-php/) `cli` |
| `.../node:<version>` | Next.js, NestJS, AdonisJS, Astro, Vite, Docusaurus |
| `.../python:<version>` | Django, FastAPI |
| `.../java`, `.../dotnet`, `.../go`, `.../rust` | Spring Boot, .NET, Gin, Axum |

Tags: `<version>` always points at the newest build; `<version>-r<YYYYMMDD>` is fixed.

## How it works
- **LaraKube CLI owns the recipe.** `larakube workspace:images --json` lists every runtime and version with its base image, and `larakube workspace:dockerfile` prints the Dockerfile. This repository holds no Dockerfiles, so a version added to the CLI is published here without an edit.
- **When it rebuilds.** Daily, a job compares each base image's digest, and a hash of the rendered Dockerfile, with the labels on the published image. A change in either rebuilds it. Run the workflow with *force* to rebuild everything.
- **What is checked.** Each image is built and started, then `scripts/smoke.sh` confirms the editor answers, the user is uid 1000 and the runtime's tools exist. Only a passing image is pushed.
- **Both architectures.** amd64 and arm64 are built on native runners and joined into one multi-arch tag.
- **code-server version.** Pinned in the LaraKube CLI. The workflow warns when a newer release is out.

## Try one locally
```bash
larakube workspace:dockerfile --runtime=php --runtime-version=8.4 > /tmp/Dockerfile
docker build -t workspace-php -f /tmp/Dockerfile /tmp
scripts/smoke.sh workspace-php php
```

## Setup (once)
After the first successful run, open each package on GitHub (Packages) and set its visibility to **public**, so servers can pull it without credentials.
