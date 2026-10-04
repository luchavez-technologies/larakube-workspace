# LaraKube workspace images

Container images for LaraKube CLI workspaces: a language toolchain, git and a browser editor
([code-server](https://github.com/coder/code-server), MIT), run on a server you own.

| Image | Frameworks |
| --- | --- |
| `ghcr.io/luchavez-technologies/larakube-workspace/php:<version>` | Laravel, Statamic, WordPress. Built on [Server Side Up](https://serversideup.net/open-source/docker-php/) `cli` |
| `.../node:<version>` | Next.js, NestJS, AdonisJS, Astro, Vite, Docusaurus |

Published today: `php` and `node`. Python, Java, .NET, Go and Rust are added to `images.json` once tested.

Tags: `<version>` always points at the newest build; `<version>-r<YYYYMMDD>` is fixed.

## What is where
- `Dockerfile`: the one recipe for every image. Build arguments pick the base image, whether to add Node, and extra PHP extensions. The Server Side Up base already carries `pdo_mysql`, `pdo_pgsql`, `zip`, `pcntl`, `redis` and the usual core ones; `images.json` lists only what is added on top (`intl`, `gd`, `bcmath`).
- `images.json`: the images that are published (runtime, version, base image, options) and the pinned code-server version. Add an entry here to publish a new runtime or version; the LaraKube CLI must also offer it.
- `scripts/smoke.sh`: starts an image and checks the editor and the runtime's tools.

## How it works
- **When it rebuilds.** Daily, a job compares each base image's digest, and a hash of the Dockerfile plus that image's options, with the labels on the published image. A change in either rebuilds just that image. Run the workflow with *force* to rebuild everything.
- **What is checked.** Each image is built and started, then `scripts/smoke.sh` confirms the editor answers, the user is uid 1000 and the runtime's tools exist. Only a passing image is pushed.
- **Both architectures.** amd64 and arm64 are built on native runners and joined into one multi-arch tag.
- **code-server.** Pinned in `images.json`; the workflow warns when a newer release is out.
- **Staying in step with the CLI.** LaraKube CLI offers runtimes and versions in its forms and pulls these images by tag. A non-blocking job reports when the two lists differ.

## Try one locally
```bash
docker build -t workspace-php \
  --build-arg BASE_IMAGE=docker.io/serversideup/php:8.4-cli \
  --build-arg CODE_SERVER_VERSION=4.140.0 \
  --build-arg INSTALL_NODE=1 \
  --build-arg PHP_EXTENSIONS="intl gd bcmath" .
scripts/smoke.sh workspace-php php
```

## Setup (once)
After the first successful run, open each package on GitHub (Packages) and set its visibility to **public**, so servers can pull it without credentials.
