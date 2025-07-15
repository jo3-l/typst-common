import * as vscode from "vscode";

import * as exportlec from "./export-lectures";
import * as impliedmult from "./implied-multiplication";

export function activate(context: vscode.ExtensionContext) {
	context.subscriptions.push(
		vscode.commands.registerCommand(impliedmult.command.id, impliedmult.command.execute),
		vscode.workspace.onWillSaveTextDocument(impliedmult.onWillSaveTextDocument),

		vscode.commands.registerCommand(exportlec.command.id, exportlec.command.execute),
	);
}
