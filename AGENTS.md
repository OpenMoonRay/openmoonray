# Agents and Automation

This repository is now maintained by [automated-ken](https://github.com/kenvandine/automated-ken), a self-hosted agentic snap-maintenance dashboard.

## What automated-ken Handles

- **Version Detection**: Automatically detects new upstream releases
- **Version Bump PRs**: Opens pull requests to bump the version
- **CI Monitoring**: Monitors build workflows and asks Copilot cloud agent to fix failing builds (with follow-up PRs)
- **YARF Testing**: Runs YARF tests
- **Channel Promotion**: Manages promotion from edge -> candidate -> stable

## Important Notes

- **Do not hand-edit the pinned version** in the snapcraft.yaml or any other version files
- The removed workflow's job is now automated-ken's responsibility
- All build and publish operations now follow the canonical pattern defined in `.github/workflows/automated-snap-build.yml`

This centralization ensures consistent maintenance practices across all snaps in the fleet.