# satosa-docker

This is the source repository of the [Docker "Official Image"](https://github.com/docker-library/official-images#what-are-official-images) for [`satosa`](https://hub.docker.com/_/satosa/).

The image description on Docker Hub is generated from [the docker-library/docs repository](https://github.com/docker-library/docs), specifically [the `satosa` directory](https://github.com/docker-library/docs/tree/master/satosa).

## See a change merged here that hasn't shown up on Docker Hub?

For more information about the Docker "Official Images" change lifecycle, see [the "An image's source changed in Git, now what?" FAQ entry](https://github.com/docker-library/faq#an-images-source-changed-in-git-now-what).

For outstanding `satosa` image PRs, check [PRs with the "library/satosa" label on the official-images repository](https://github.com/docker-library/official-images/labels/library%2Fsatosa). For the current "source of truth" for the `satosa` image, see [the `library/satosa` file in the official-images repository](https://github.com/docker-library/official-images/blob/master/library/satosa).

---

-	[![build status badge](https://img.shields.io/github/workflow/status/IdentityPython/satosa-docker/GitHub%20CI/main?label=GitHub%20CI)](https://github.com/IdentityPython/satosa-docker/actions?query=workflow%3A%22GitHub+CI%22+branch%3Amain)

| Build | Status | Badges | (per-arch) |
|:-:|:-:|:-:|:-:|
| [![amd64 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/amd64/job/satosa.svg?label=amd64)](https://doi-janky.infosiftr.net/job/multiarch/job/amd64/job/satosa/) | [![arm32v5 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/arm32v5/job/satosa.svg?label=arm32v5)](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v5/job/satosa/) | [![arm32v6 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/arm32v6/job/satosa.svg?label=arm32v6)](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v6/job/satosa/) | [![arm32v7 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/arm32v7/job/satosa.svg?label=arm32v7)](https://doi-janky.infosiftr.net/job/multiarch/job/arm32v7/job/satosa/) |
| [![arm64v8 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/arm64v8/job/satosa.svg?label=arm64v8)](https://doi-janky.infosiftr.net/job/multiarch/job/arm64v8/job/satosa/) | [![i386 build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/i386/job/satosa.svg?label=i386)](https://doi-janky.infosiftr.net/job/multiarch/job/i386/job/satosa/) | [![mips64le build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/mips64le/job/satosa.svg?label=mips64le)](https://doi-janky.infosiftr.net/job/multiarch/job/mips64le/job/satosa/) | [![ppc64le build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/ppc64le/job/satosa.svg?label=ppc64le)](https://doi-janky.infosiftr.net/job/multiarch/job/ppc64le/job/satosa/) |
| [![s390x build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/multiarch/job/s390x/job/satosa.svg?label=s390x)](https://doi-janky.infosiftr.net/job/multiarch/job/s390x/job/satosa/) | [![put-shared build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/put-shared/job/light/job/satosa.svg?label=put-shared)](https://doi-janky.infosiftr.net/job/put-shared/job/light/job/satosa/) |

---

## Coding Style

Please follow the style of the other Docker Official Images.  In particular, use tabs for indentation instead of spaces.

## Git Commit Messages

Please follow [Angular Commit Message Conventions](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#-commit-message-format). The following scopes are currently in use:
- **docker-entrypoint**: the Dockerfile ENTRYPOINT scripts; currently only [docker-entrypoint.sh](docker-entrypoint.sh)
- **docker-library**: the Docker Official Images library entry generator; currently only [generate-stackbrew-library.sh](generate-stackbrew-library.sh)
- **dockerfile-linux**: all Linux variants of the container image itself; includes [Dockerfile-linux.template](Dockerfile-linux.template) and the corresponding variant image definitions in the SATOSA version-specific directories, e.g., [8.1/bullseye](8.1/bullseye)
- **dockerfile-windows**: currently unused
- **git**: Git repository configuration or GitHub-specific files; includes [.gitignore](.gitignore), [.gitattributes](.gitattributes), and [the GitHub Actions workflows](.github/workflows)
- **license**: software licensing information; currently only [LICENSE.md](LICENSE.md)
- **readme**: this file
- **templating**: the gawk/jq-based templating engine itself, as opposed to the templates; currently only [apply-templates.sh](apply-templates.sh)
- **update**: a helper script that executes both the version tracker and templating engine; currently only [update.sh](update.sh)
- **versions**: the SATOSA version tracker; includes [versions.sh](versions.sh) and [versions.json](versions.json)

## Development Environment

To develop Docker Official Images, please install [bashbrew](https://github.com/docker-library/bashbrew), the Docker Official Images build tool:
```bash
git clone --depth=1 https://github.com/docker-library/bashbrew; \
( \
    umask 0022; \
    cd bashbrew; \
    go mod download; \
    ./bashbrew.sh --version; \
    sudo cp bin/bashbrew /usr/local/bin/ \
); \
rm -rf bashbrew
```
Bashbrew uses [manifest-tool](https://github.com/estesp/manifest-tool) to generate the shared tag index:
```bash
git clone --depth=1 https://github.com/estesp/manifest-tool; \
( \
    umask 0022; \
    cd manifest-tool; \
    make binary; \
    sudo cp manifest-tool /usr/local/bin/ \
); \
rm -rf manifest-tool
```
Please make note of these tools' dependencies, in particular [GNU Make](https://www.gnu.org/software/make/) and [Go](https://go.dev/).

The templating engine and version tracker require [jq](https://stedolan.github.io/jq/) and [GNU awk](https://www.gnu.org/software/gawk/).

Use [qemu-user-static](https://github.com/multiarch/qemu-user-static) to work with multi-architecture containers.

In forks of this repository, enable both GitHub Actions and the GitHub CI workflow after reviewing the workflow definitions.

Before cloning the repository or working within it, set the [file mode creation mask](https://en.wikipedia.org/wiki/Umask) to `0022` or `u=rwx,g=rx,o=rx`.

## Update Process

1. If necessary, update the list of version aliases at the beginning of `generate-stackbrew-library.sh`.

2. Update `versions.json` and the container image definitions by running `update.sh`. Specify the desired major and minor version of SATOSA. For example:
   ```bash
   ./update.sh 8.1
   ```

3. If necessary, remove outdated versions of SATOSA or the base container images from `versions.json`. Delete the corresponding SATOSA container image definitions, e.g., `8.0/`, `8.1/*alpine3.14*/`.

4. Commit all of the modified files. Mention the new SATOSA or base container version in the commit message subject. Reference the release announcement in the commit message body. For example:
   ```
   feat(*): version bump to SATOSA v8.1.0

   Cf. https://github.com/IdentityPython/SATOSA/commit/d44b54433c5b817cf0409855881f6f2c80c27f5c
   ```
   Or for example:
   ```
   feat(*): version bump to Alpine Linux v3.16

   Cf. https://www.alpinelinux.org/posts/Alpine-3.16.0-released.html
   ```

5. GitHub Actions will run two workflows on push. [Verify Templating](actions/workflows/verify-templating.yml) checks for uncommitted changes. [GitHub CI](actions/workflows/ci.yml) builds and tests all of the container images.

6. If both workflows complete successfully, generate a new [Docker Official Images](https://github.com/docker-library/official-images/) library entry by running the following command:
   ```bash
   ./generate-stackbrew-library.sh
   ```

7. Fork and edit [the Docker Official Images library entry for SATOSA](https://github.com/docker-library/official-images/edit/master/library/satosa). Replace its contents with the output of `generate-stackbrew-library.sh`. Use a commit message referencing the release announcement. Submit a pull request when done. For example:
   ```
   Update SATOSA to v8.0.1

   Cf. https://github.com/IdentityPython/SATOSA/commit/1a408439a6b8855346e5ca2c645dee6ab1ce8c0a
   ```
   Or for example:
   ```
   Update SATOSA base container images to Alpine Linux v3.16

   Cf. https://www.alpinelinux.org/posts/Alpine-3.16.0-released.html
   ```
