import { app, BrowserWindow } from "electron";
import * as path from "node:path";
import { bindWindowToLune, watchForChanges } from "electron-lune-bindings";
import * as config from "./lune-config.json";
import * as child_process from "child_process";

let win: BrowserWindow | undefined = undefined;
__dirname = path.resolve(__dirname, "../"); // from ./dist to project directory

function createWindow() {
  win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, "/dist/src-js/preload.js"),
    },
  });

  win.loadFile("public/index.html").catch((err) => {
    console.error(err);
  });
}

app.whenReady().then(() => {
  createWindow();

  if (!win) return;

  bindWindowToLune(
    win,
    () =>
      // dev
      child_process.spawn("lune", ["run", config.mainScript], {
        cwd: __dirname,
      }),
    () =>
      // production
      child_process.spawn(config.executable, {
        cwd: __dirname,
      }),
    config.lunePort
  );

  watchForChanges(win, __dirname);

  console.info(
    "Create a new shell instance and run 'tsc -w' inside of it to compile typescript files while the app is running\nif you're a vscode user you can run the 'tsc: watch' task"
  );

  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    app.quit();
  }
});
