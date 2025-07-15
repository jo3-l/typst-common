import * as child_process from "node:child_process";
import { access } from "node:fs/promises";
import * as path from "node:path";
import { promisify } from "node:util";
import * as vscode from "vscode";

import { makeCommand, tryOrDisplayError, UserFacingError } from "./command-base";

const { showInformationMessage, showErrorMessage } = vscode.window;
const exec = promisify(child_process.exec);

const NOTES_FILE = "notes.typ";
const OUTPUT_FILE = "exported-lectures.pdf";

export const command = makeCommand({
	id: "typst-helpers.exportLectureNotes",
	execute,
});

async function execute() {
	const workspaceFolder = vscode.workspace.workspaceFolders?.[0].uri.fsPath;
	if (!workspaceFolder) {
		showErrorMessage("No workspace open");
		return;
	}

	const notesPath = path.join(workspaceFolder, NOTES_FILE);
	await tryOrDisplayError(() => access(notesPath), "Could not find notes document in workspace");

	const queryCmd = `typst query ${NOTES_FILE} "<lecture-marker> --field value`;
	const { stdout } = await tryOrDisplayError(
		() =>
			exec(queryCmd, {
				cwd: workspaceFolder,
				encoding: "utf-8",
			}),
		"Failed querying document metadata",
	);
	const lectureItems = parseDocMetadata(stdout);

	// Reverse to show most recent lectures first.
	const selectedLectures = await vscode.window.showQuickPick([...lectureItems].reverse(), {
		placeHolder: "Select lectures to export",
		canPickMany: true,
	});
	if (!selectedLectures) return;

	const selectedPages = selectedLectures.map((lec) => `${lec.startPage}-${lec.endPage}`).join(",");
	const exportCmd = `typst compile ${NOTES_FILE} --pages ${selectedPages} ${OUTPUT_FILE}`;
	try {
		await exec(exportCmd, { cwd: workspaceFolder });
		showInformationMessage(`Exported selected lectures to '${OUTPUT_FILE}'`);
	} catch {
		showErrorMessage("Failed exporting selected lectures");
	}
}

type LectureMarkerMetadata =
	| {
			kind: "start";
			lec: number;
			date: string;
			page: number;
	  }
	| { kind: "end"; page: number };

interface LectureItem extends vscode.QuickPickItem {
	startPage: number;
	endPage: number;
}

function parseDocMetadata(queryStdout: string): LectureItem[] {
	const markers = JSON.parse(queryStdout) as LectureMarkerMetadata[];
	if (markers.length % 2 !== 0) throw new UserFacingError("Malformed document metadata");

	const items: LectureItem[] = [];
	for (const [marker, endMarker] of nonOverlappingPairs(markers)) {
		if (marker.kind !== "start" || endMarker.kind !== "end") throw new UserFacingError("Malformed document metadata");

		items.push({
			label: `Lecture ${marker.lec}`,
			description: marker.date,
			startPage: marker.page,
			endPage: endMarker.page,
		});
	}
	return items;
}

function* nonOverlappingPairs<T>(xs: T[]): IterableIterator<[T, T]> {
	if (xs.length % 2 !== 0) throw new Error("odd length in nonOverlappingPairs");
	for (let i = 0; i < xs.length; i += 2) {
		yield [xs[i], xs[i + 1]];
	}
}
