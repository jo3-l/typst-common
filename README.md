# `typst-common`

Shared files for my horribly overengineered note-taking setup using Typst.

- `lib/` holds shared Typst template files.
	- It's not a `@local/` package since it includes multiple files. While I could split it into multiple `@local/` packages, the files are coupled together pretty tightly so code reusability is a concern. Instead, I clone this folder using a sparse checkout into every workspace that requires it, which also allows for local per-project modifications.

- `vscode-extension/` is a personal VS Code extension.
	- It provides two helper commands: fix implied multiplication errors, and export selected lectures from a course notes document using my template.

## License

MIT
