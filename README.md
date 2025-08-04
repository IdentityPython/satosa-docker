[![Docker Hub star count badge](https://img.shields.io/docker/stars/_/satosa.svg)](https://hub.docker.com/_/satosa)
[![Docker Hub pull count badge](https://img.shields.io/docker/pulls/_/satosa.svg)](https://hub.docker.com/_/satosa)
[![GitHub CI build status badge](https://img.shields.io/github/actions/workflow/status/IdentityPython/satosa-docker/ci.yml?branch=main&label=GitHub%20CI)](https://github.com/IdentityPython/satosa-docker/actions?query=workflow%3A%22GitHub+CI%22+branch%3Amain)
[![repo-info build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/repo-info/job/local/job/satosa.svg?label=repo-info)](https://doi-janky.infosiftr.net/job/repo-info/job/local/job/satosa/)
[![put-shared build status badge](https://img.shields.io/jenkins/s/https/doi-janky.infosiftr.net/job/put-shared/job/light/job/satosa.svg?label=put-shared)](https://doi-janky.infosiftr.net/job/put-shared/job/light/job/satosa/)

# satosa-docker

This is the source repository of the
[Docker "Official Image"](https://github.com/docker-library/official-images#what-are-official-images)
for [`satosa`](https://hub.docker.com/_/satosa/).

The image description on Docker Hub is generated from
[the docker-library/docs repository](https://github.com/docker-library/docs),
specifically
[the `satosa` directory](https://github.com/docker-library/docs/tree/master/satosa).


## See a change merged here that hasn't shown up on Docker Hub?

For more information about the Docker "Official Images" change
lifecycle, see
[the "An image's source changed in Git, now what?" FAQ entry](https://github.com/docker-library/faq#an-images-source-changed-in-git-now-what).

For outstanding `satosa` image PRs, check
[PRs with the "library/satosa" label on the official-images repository](https://github.com/docker-library/official-images/labels/library%2Fsatosa).
For the current "source of truth" for the `satosa` image, see
[the `library/satosa` file in the official-images repository](https://github.com/docker-library/official-images/blob/master/library/satosa).


# Contributing

This project uses the
[Git feature branch workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow).
Please submit your changes for review as a
[GitHub pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests).

In forks of this repository, enable the GitHub Actions workflows.
GitHub Actions runs two workflows when developers push commits to a
branch.  [Verify Templating](actions/workflows/verify-templating.yml)
checks for uncommitted changes.  [GitHub CI](actions/workflows/ci.yml)
builds and tests the container images.


## Development Environment

This project uses the following software:

- [Docker 20.10 or newer](https://docs.docker.com/engine/install/)

- [GNU awk](https://www.gnu.org/software/gawk/),
  [GNU Find Utilities](https://www.gnu.org/software/findutils/),
  [GNU Wget](https://www.gnu.org/software/wget/), and
  [jq](https://stedolan.github.io/jq/) for the templating engine and
  version tracker

- [GNU Make](https://www.gnu.org/software/make/) and
  [Go](https://go.dev/), required by bashbrew and manifest-tool

- [bashbrew](https://github.com/docker-library/bashbrew), the Docker
  Official Images build tool

- [manifest-tool](https://github.com/estesp/manifest-tool), which
  generates the shared tag index

- (optional; Linux-amd64 build hosts only)
  [qemu-user-static](https://github.com/multiarch/qemu-user-static)
  to test containers on other hardware architecture via emulation

Before cloning the repository or working within it, set the
[file mode creation mask](https://en.wikipedia.org/wiki/Umask) to
`0022` or `u=rwx,g=rx,o=rx`.


## Coding Style

Follow
[the Docker Official Images review guidelines](https://github.com/docker-library/official-images#review-guidelines)
and
[Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/).

In Dockerfiles and shell scripts, please use tabs for indentation
instead of spaces.


## Commit Messages

This project uses
[Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).
Valid commit types are:

- **build**—changes to the build system or external dependencies

- **ci**—changes to the CI configuration files and scripts

- **docs**—documentation-only changes

- **feat**—a new feature

- **fix**—a bug fix

- **perf**—a code change that improves performance

- **refactor**—a code change that neither fixes a bug nor adds a feature

- **test**—new tests or corrections to existing tests

No commit scopes are currently in use.


## Update Process

In a fork of this repository:

1. Review the list of version aliases at the beginning of
   `generate-stackbrew-library.sh`.

2. Run [update.sh](update.sh), specifying the desired major and minor
   version of SATOSA. For example:

```bash
./update.sh 8.1
```

3. Remove outdated versions of SATOSA or base container images from
   `versions.json`, and delete the corresponding SATOSA container
   image definitions from the repository, e.g., the `8.0/` or
   `8.1/*alpine3.14*/` folders.

4. Mention the new SATOSA or base container version in the commit
   message subject, and reference the release announcement in the
   commit message body. For example:

```
feat: version bump to SATOSA v8.1.0

Cf. https://github.com/IdentityPython/SATOSA/commit/d44b54433c5b817cf0409855881f6f2c80c27f5c
```

5. Submit a pull request after both GitHub Actions workflows complete
   successfully.

6. After accepting a pull request, fork and edit
   [the Docker Official Images library entry for SATOSA](https://github.com/docker-library/official-images/edit/master/library/satosa).

7. Replace the library entry's contents with the output of
   [generate-stackbrew-library.sh](generate-stackbrew-library.sh).

8. Again, use a commit message referencing the release announcement.
   For example:

```
feat: version bump to Alpine Linux v3.16

Cf. https://www.alpinelinux.org/posts/Alpine-3.16.0-released.html
```

9. Submit a pull request when finished.
