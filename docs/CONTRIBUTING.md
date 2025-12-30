# Contributing to BlockScore

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/abrar2030/BlockScore.git`
3. Create a branch: `git checkout -b feature/your-feature`
4. Make changes and commit: `git commit -m "Add feature"`
5. Push and open a Pull Request

## Code Standards

### Python

- Follow PEP 8 style guide
- Use Black for formatting: `black code/backend/`
- Run tests: `pytest`

### JavaScript/TypeScript

- Use ESLint and Prettier
- Run linter: `npm run lint`
- Fix automatically: `npm run lint:fix`

### Solidity

- Follow Solidity style guide
- Use Solhint: `solhint contracts/**/*.sol`

## Testing

- Write tests for new features
- Maintain >70% code coverage
- Run all tests before submitting PR

## Pull Request Process

1. Update documentation for new features
2. Ensure all tests pass
3. Update CHANGELOG.md
4. Request review from maintainers

See [README.md](../README.md) for more details.
