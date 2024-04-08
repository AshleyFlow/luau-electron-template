import path from "path";
import * as config from "./src/config.json";
import * as child_process from "child_process";
import { readFileSync, writeFile } from "fs";

let regex = /Writing standalone binary to (.+)/;
__dirname = path.resolve(__dirname, "../");

let build = child_process.spawn("lune", ["build", config.mainScript], {
  cwd: __dirname,
});

build.stdout.on("data", (chunk: Buffer) => {
  let stdout = chunk.toString();
  let output = stdout.match(regex);

  if (output) {
    let executable = output[1];
    console.log("Built executable file for lune: " + executable);

    let newConfig: typeof config = JSON.parse(
      readFileSync("./src/config.json", "utf8")
    );

    newConfig.executable = executable;

    writeFile(
      "./src/config.json",
      JSON.stringify(newConfig, null, "\t"),
      "utf8",
      (err) => {
        if (!err) return;

        console.error("Failed while writing to config.json");
      }
    );
  }
});
