import assert from "node:assert/strict";
import { mkdtemp, rm, writeFile } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { startPresentationServer } from "../R/serve_presentation.mjs";

test("presenter server exposes only the standalone presentation", async () => {
  const directory = await mkdtemp(path.join(os.tmpdir(), "presentation-server-"));
  const htmlPath = path.join(directory, "presentation.html");
  await writeFile(htmlPath, "<!doctype html><title>Deck</title>", "utf8");
  const { server, url } = await startPresentationServer({
    htmlPath,
    port: 0,
    openBrowser: false
  });
  try {
    const presentation = await fetch(url);
    assert.equal(presentation.status, 200);
    assert.equal(await presentation.text(), "<!doctype html><title>Deck</title>");
    assert.equal(presentation.headers.get("cache-control"), "no-store");
    const missing = await fetch(new URL("/private.txt", url));
    assert.equal(missing.status, 404);
  } finally {
    await new Promise((resolve) => server.close(resolve));
    await rm(directory, { recursive: true, force: true });
  }
});
