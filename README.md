# `typst-common`

Shared files for my horribly overengineered note-taking setup using Typst.

- `lib/` holds shared Typst template files.
	- It's not a `@local/` package since there are multiple files. While I could split it into multiple `@local/` packages, the files are coupled together pretty tightly so code reusability is a concern. Instead, I clone this folder using a sparse checkout into every workspace that requires it, which also allows for local per-project modifications.

- `vscode-extension/` is a personal VS Code extension providing some helper commands.
	- Fix implied multiplication errors + export selected lectures.

## License

MIT
