import * as vscode from "vscode";

export interface Command {
	id: string;
	execute(): void;
}

export function makeCommand(cmd: Command): Command {
	return {
		id: cmd.id,
		async execute() {
			try {
				await cmd.execute();
			} catch (error) {
				if (error instanceof UserFacingError) {
					vscode.window.showErrorMessage(error.message);
				} else {
					throw error;
				}
			}
		},
	};
}

/** An error that will be displayed to the user via `vscode.window.showErrorMessage`. */
export class UserFacingError extends Error {}

export async function tryOrDisplayError<T>(f: () => T | Promise<T>, error: string): Promise<T> {
	try {
		return f();
	} catch {
		throw new UserFacingError(error);
	}
}
