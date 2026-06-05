# Publish SOPS env action

Composite GitHub Action that renders an env manifest from GitHub Secrets/Variables, encrypts it for named age recipients, and publishes it as an OCI artifact.

## Usage

```yaml
- uses: ./.github/actions/publish-sops-env
  with:
    manifest: projects/docker-apps/mainframe.yml
    keys-directory: keys
    token: ${{ secrets.GITHUB_TOKEN }}
  env:
    GITHUB_SECRETS_JSON: ${{ toJson(secrets) }}
    GITHUB_VARS_JSON: ${{ toJson(vars) }}
```

The calling job requires:

```yaml
permissions:
  contents: read
  packages: write
```

## Manifest

```yaml
package: ghcr.io/dupmachine/docker-apps--mainframe
keys:
  - master
  - mainframe
env:
  APPS_DOMAIN: APPS_DOMAIN
  APPS_TIMEZONE: APPS_TIMEZONE
```

For each name in `keys`, the action loads `<keys-directory>/<name>.pub`. Secrets win over Variables when both contexts contain the same source key.

The action publishes `.sops.env` as the artifact payload. Removing `.sops` gives the target plaintext filename, `.env`.

The action publishes the first eight characters of `GITHUB_SHA` as an immutable tag and updates `latest`. Override these with the `tag` and `latest-tag` inputs.
