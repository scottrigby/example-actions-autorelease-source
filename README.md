# Example Auto-Release Source

Test repository for automated release workflows.

## Usage

Run "Prepare Release" workflow with target version (e.g., v3.2.0)

See [Release Process](https://github.com/scottrigby/example-actions-autorelease-docs/blob/main/docs/release-process.md) for detailed steps.

## Repo Setup

1. Create fine-grained personal access token:
   - Go to GitHub Settings > Developer settings > Personal access tokens > Fine-grained tokens
   - Select "Selected repositories" and add both scottrigby repos
   - Grant permissions: Contents (Read/Write), Pull requests (Write), Metadata (Read)

2. Add token as repository secret:
   - Go to Settings > Secrets and variables > Actions
   - Create secret named `DOCS_TOKEN` with the token value

## Links

- [Documentation Repository](https://github.com/scottrigby/example-actions-autorelease-docs)
