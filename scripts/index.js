#!/usr/bin/env node

import fs from "fs";
import path from "path";
import inquirer from "inquirer";
import { fileURLToPath } from "url";
import { exec } from "child_process";

const getDir = () => {
  const __filename = fileURLToPath(import.meta.url);
  const dirname = path.dirname(__filename);
  const currentDir = process.cwd();
  return [dirname, currentDir];
};

const initialChoices = (currentDir) => {
  const choices = fs.readdirSync(currentDir).map((choice) => ({
    name: choice,
    value: choice,
  }));
  return choices;
};

const inquirerSecond = (projectType) => {
  const [dirname, currentDir] = getDir();
  const choices = initialChoices(currentDir);

  inquirer
    .prompt([
      {
        type: "checkbox",
        name: "projectSelects",
        message: "[?] Lựa chọn thư mục dự án:",
        choices: choices,
        pageSize: 20,
      },
    ])
    .then((answers) => {
      const scriptPath = dirname + "/shells/" + projectType + ".sh";

      exec(
        `sh ${scriptPath} ` + (answers.projectSelects || []).join(" "),
        (error, stdout, stderr) => {
          if (error) {
            console.error(`Error executing script: ${error.message}`);
            return;
          }

          if (stderr) {
            console.error(`Script error output: ${stderr}`);
            return;
          }

          console.log(`Script output:\n${stdout}`);
        }
      );
    })
    .catch((error) => {
      console.error("Error:", error);
    });
};

const inquirerStart = () => {
  inquirer
    .prompt([
      {
        type: "list",
        name: "projectType",
        message: "[?] Lựa chọn loại dự án:",
        choices: [
          { name: "[FE] Frontend", value: "FE" },
          { name: "[BE] Backend", value: "BE" },
        ],
      },
    ])
    .then((answer) => {
      if (answer) {
        inquirerSecond(answer.projectType);
      }
    })
    .catch((error) => {
      console.error("Error:", error);
    });
};

inquirerStart();
