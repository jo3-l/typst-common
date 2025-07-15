import * as vscode from "vscode";
import { makeCommand } from "./command-base";

const SURROUNDING_LINE_RADIUS = 2;

export const command = makeCommand({
	id: "typst-helpers.fixImpliedMultiplication",
	execute,
});

function execute() {
	const editor = vscode.window.activeTextEditor;
	if (!editor) return;

	const errors = findErrors(editor);
	const edit = new vscode.WorkspaceEdit();
	for (const error of errors) {
		const fix = generateFix(editor.document, error.range);
		edit.replace(editor.document.uri, fix.range, fix.newText);
	}
	vscode.workspace.applyEdit(edit);
	vscode.workspace.save(editor.document.uri);
}

export function onWillSaveTextDocument(event: vscode.TextDocumentWillSaveEvent) {
	const doc = event.document;
	if (doc.languageId !== "typst") return;

	const editor = vscode.window.activeTextEditor;
	if (!editor) return;

	const errors = findErrors(editor);
	const edits = errors.map((error) => generateFix(editor.document, error.range));
	event.waitUntil(Promise.resolve(edits));
}

function findErrors(editor: vscode.TextEditor): vscode.Diagnostic[] {
	const line = editor.selection.active.line;
	const diagnostics = vscode.languages.getDiagnostics(editor.document.uri);
	const impliedMultiplicationErrors = diagnostics
		.filter(
			(diag) =>
				Math.abs(diag.range.start.line - line) <= SURROUNDING_LINE_RADIUS &&
				diag.severity === vscode.DiagnosticSeverity.Error,
		)
		.filter((err) => isImpliedMultiplicationError(err.message));

	return impliedMultiplicationErrors;
}

function isImpliedMultiplicationError(message: string) {
	return message.includes("unknown variable") && message.includes("try adding spaces between each letter");
}

function generateFix(doc: vscode.TextDocument, range: vscode.Range): vscode.TextEdit {
	const orig = doc.getText(range);
	const fixed = [...orig].join(" ");
	return new vscode.TextEdit(range, fixed);
}
