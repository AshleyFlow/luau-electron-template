import path from "path";
import * as config from "./lune-config.json";
import * as child_process from "child_process";
import { readFileSync, unlinkSync, writeFile } from "fs";

const luneConfigPath = "./lune-config.json";
const fullRegex = /Writing standalone binary to (.+)/;
const extensionRegex = /\..+/;
const directoryRegex = /.*\//;

__dirname = path.resolve(__dirname, "../");

let buildSample = child_process.spawnSync(
  "lune",
  ["build", config.mainScript],
  {
    cwd: __dirname,
  }
);

let extension = "";
let cwd = "";

buildSample.output.forEach((chunk) => {
  if (!chunk) return;
  let stdout = chunk.toString();
  let fullRegexResults = stdout.match(fullRegex);

  if (fullRegexResults) {
    let sampleExecutable = fullRegexResults[1];
    let directoryRegexResults = fullRegexResults[1].match(directoryRegex);
    let extensionRegexResults = fullRegexResults[1].match(extensionRegex);
    extension = extensionRegexResults ? extensionRegexResults[0] : "";
    cwd = directoryRegexResults ? directoryRegexResults[0] : "src";

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
  let output = stdout.match(fullRegex);

  if (output) {
    let executable = output[1];
    console.log("Built executable file for lune: " + executable);

    let newConfig: typeof config = JSON.parse(
      readFileSync(luneConfigPath, "utf8")
    );

    newConfig.executable = path.relative(cwd, executable);
    newConfig.cwd = cwd;

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
