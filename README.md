# Automated Release Example

This repository demonstrates automated release workflows with GPG signing and human review gates.

## GitHub Actions Setup

1. **Generate GPG key**: Run `make container-run` then `make generate-gpg-key` inside the container
2. **Commit public key**: The make target adds the public key to the KEYS file - commit and push this change
3. **Copy private key**: Copy contents of `private-key.asc` to GitHub repository secret `GPG_PRIVATE_KEY`
4. **Copy passphrase**: Copy contents of `passphrase.txt` to GitHub repository secret `GPG_PASSPHRASE`
5. **Create release token**: [Fine-grained Personal Access Token](https://github.com/settings/personal-access-tokens/new) with permissions:
   - Contents: Read/Write
   - Pull requests: Write
   - Metadata: Read
   - Actions: Write
6. **Add token**: Save token as `RELEASE_TOKEN` repository secret

## Usage

1. Run ["Release" workflow](https://github.com/scottrigby/example-actions-autorelease-source/actions/workflows/release.yml) with target version
2. Review and publish the draft release (created automatically)
3. Documentation is automatically updated

## How It Works

- **Manual trigger**: Maintainers initiate releases via workflow dispatch
- **GPG signed artifacts**: All releases are cryptographically signed
- **Draft releases**: Created for review before triggering docs
- **Cross-repo automation**: Automatically updates documentation

## Available Make Targets

Run `make help` to see all available commands including container-based verification.

**Note:** Only `make container-*` commands are run on the host. All other commands should be run inside the container.

## Links

- [Documentation Repository](https://github.com/scottrigby/example-actions-autorelease-docs)
- [Release Process Details](https://github.com/scottrigby/example-actions-autorelease-docs/blob/main/docs/release-process.md)
