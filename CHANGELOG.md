# Changelog

## [v0.0.4] - 2026-06-13

- fix changelog trailing newline
- upload release artifact separately after create-release
- add dependabot, automerge, pre-commit autoupdate, telegram notify; pin baseline to v0.0.12
- pin baseline actions to v0.0.10
- scope generated app env files
- rename publish.yml to release.yml
- use composite lint actions from baseline
- split publish into build-bundle + create-release actions
- update baseline repo references
- update README: fix zip bundle, remove moved publish-app-bundle action
- remove local publish-app-bundle action, moved to dupmachine/workflows
- use publish-app-bundle action from dupmachine/workflows
- chore: update changelog for v0.0.3

## [v0.0.3] - 2026-06-12

- generate AI release notes and update CHANGELOG.md on publish
- move homepage from docker-apps-extra to core bundle
- update latest release target commit on each publish
