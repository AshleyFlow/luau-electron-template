import path from "path";
import * as config from "./lune-config.json";
import * as child_process from "child_process";
import { readFileSync, unlinkSync, writeFile } from "fs";

const luneConfigPath = "./lune-config.json";
const regex = /Writing standalone binary to (.+)/;
const extensionRegex = /(\..+)/;

__dirname = path.resolve(__dirname, "../");

let buildSample = child_process.spawnSync(
  "lune",
  ["build", config.mainScript],
  {
    cwd: __dirname,
  }
);

let extension = "";

buildSample.output.forEach((chunk) => {
  if (!chunk) return;
  let stdout = chunk.toString();
  let output = stdout.match(regex);

  if (output) {
    let sampleExecutable = output[1];
    let extensionRegexResults = output[1].match(extensionRegex);
    extension = extensionRegexResults ? extensionRegexResults[1] : "";

    unlinkSync(sampleExecutable);
  }
});

let build = child_process.spawn(
  "lune",
  ["build", config.mainScript, "-o", "./executables/build" + extension],
  {
    cwd: __dirname,
  }
);

build.stdout.on("data", (chunk: Buffer) => {
  let stdout = chunk.toString();
  let output = stdout.match(regex);

  if (output) {
    let executable = output[1];
    console.log("Built executable file for lune: " + executable);

    let newConfig: typeof config = JSON.parse(
      readFileSync(luneConfigPath, "utf8")
    );

    newConfig.executable = executable;

    writeFile(
      luneConfigPath,
      JSON.stringify(newConfig, null, "\t"),
      "utf8",
      (err) => {
        if (!err) return;

        console.error("Failed while writing to config.json");
      }
    );
  }
});
