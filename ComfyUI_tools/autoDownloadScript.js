// ==UserScript==
// @name         change font size
// @namespace    http://tampermonkey.net/
// @version      2026-01-17
// @description  try to take over the world!
// @author       You
// @match        https://*.unicorn.org.cn*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=unicorn.org.cn
// @grant        none
// ==/UserScript==

(function () {
  "use strict";

  backgroundDownload();
})();

async function backgroundDownload() {
  await waitForApi();

  console.log("[userscript] Background Download active");
  app.api.addEventListener("executed", async (e) => {
    const output = e.detail;
    const item = Object.values(Object.values(output)[0]);
    const filename = Object.values(e.detail.output)[0][0].filename;
    const filetype = Object.values(e.detail.output)[0][0].type;

    if (filetype !== "temp") return;

    const url =
      new URL(window.location).origin + "/api/view?filename=" + filename;
    +"?subfolder=?type=temp";
    console.log("download URL: ", url);

    try {
      const response = await fetch(url);
      const blob = await response.blob();

      // Send the image to your LOCAL Python server
      await fetch("http://127.0.0.1:8888", {
        method: "POST",
        headers: {
          "Content-Type": "application/octet-stream",
          "X-Filename": filename,
        },
        body: blob,
      });

      console.log(`Silently pushed to local drive: ${filename}`);
    } catch (err) {
      console.error("Local relay not running? Run the Python script!", err);
    }
  });
}

async function waitForApi() {
  console.log("[userscript] Waiting for ComfyUI API to initialize...");

  if (app && app.api) {
    return;
  }

  await sleep(1000);
  await waitForApi();
}

async function sleep(ms) {
  new Promise((resolve) => setTimeout(resolve, ms));
}
