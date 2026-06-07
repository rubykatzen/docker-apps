# Publish Docker Apps bundle

Composite GitHub Action that builds, verifies, and publishes a Docker Apps bundle as a GitHub Release asset.

## Usage

```yaml
- uses: ./.github/actions/publish-app-bundle
  with:
    bundle-name: docker-apps.tar.gz
    token: ${{ secrets.GITHUB_TOKEN }}
    paths: |
      apps
      .env.example
      apps.env.example
      backup.sh
      down.sh
      lib.sh
      logs.sh
      restart.sh
      up.sh
      README.md
```

The action publishes an immutable short-SHA release tag and updates the `latest` release asset by default.

External repositories can use the action by referencing this repository:

```yaml
- uses: dupmachine/docker-apps/.github/actions/publish-app-bundle@main
```
