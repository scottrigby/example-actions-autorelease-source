# Example Auto-Release Source

Test repository for automated release workflows.

## Usage

Run ["Prepare Release" workflow](https://github.com/scottrigby/example-actions-autorelease-source/actions/workflows/prepare-release.yml) with target version (e.g., v3.2.0)

See [Release Process](https://github.com/scottrigby/example-actions-autorelease-docs/blob/main/docs/release-process.md) for detailed steps.

## Repo Setup

1. Create `dev-v3` branch from main and set version.json to v3.1.0
2. Update main branch version.json to v4.0.0-alpha.1
3. [Create fine-grained personal access token](https://github.com/settings/personal-access-tokens/new):
   - Select "Selected repositories" and add both the example source and docs repos
   - Grant permissions: Contents (Read/Write), Pull requests (Write), Metadata (Read)
4. [Add token as repository secret](https://github.com/scottrigby/example-actions-autorelease-source/settings/secrets/actions/new):
   - Create secret named `RELEASE_TOKEN` with the token value

## Links

- [Documentation Repository](https://github.com/scottrigby/example-actions-autorelease-docs)
