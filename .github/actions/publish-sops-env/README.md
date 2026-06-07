# Publish SOPS env action

Composite GitHub Action that renders an env manifest from GitHub Secrets/Variables, encrypts it for named age recipients, and publishes `.sops.env` as a GitHub Release asset.

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
  contents: write
```

## Manifest

```yaml
release_asset: mainframe.sops.env
keys:
  - master
  - mainframe
env:
  APPS_DOMAIN: APPS_DOMAIN
  APPS_TIMEZONE: APPS_TIMEZONE
```

For each name in `keys`, the action loads `<keys-directory>/<name>.pub`. Secrets win over Variables when both contexts contain the same source key.

The action uploads the encrypted env using `release_asset`, defaulting to `<manifest-stem>.sops.env`.

The action publishes to the current repository by default. Override that with `release-repo`, or set `release_repo` in the manifest. The release tag defaults to `release_tag` from the manifest or the current repository name.
