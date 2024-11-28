// init the page

if (window.location.href.includes("settings")) {
  init();
}

async function init() {
  console.log("init");
  setInterval(() => {
    // Remove Mask
    console.log("ran remove mask");
    document
      .querySelectorAll(
        "div.absolute.top-0.left-0.w-full.h-full.p-12.flex.flex-col.items-center.justify-center.c-text-secondary.z-2.bg-bg-on-secondary.gap-8",
      )
      .forEach((item) => console.log(item.classList.remove("absolute")));
  }, 1000);

  await sleep(1000);
  openPanel();

  await sleep(5000);
  expandPromptTextArea();
  expendNegPromptTextArea();
  expendWorkSpace();
}

function openPanel() {
  console.log("clicked create to open panel");

  document.querySelectorAll("div").forEach((item) => {
    const content = item.textContent;
    if (content === " Create") {
      item.click();
    }
  });
}

function expandPromptTextArea() {
  console.log("resize textarea");
  document.querySelectorAll(
    ".overflow-hidden.flex.rd-12.resize-y",
  )[0].style.height = "800px";
}

function expendNegPromptTextArea() {
  const textareas = [...document.querySelectorAll("textarea")];
  textareas.forEach((item) => (item.rows = 15));
}

function expendWorkSpace() {
  const workspace = document.querySelector(".workspace-core");
  workspace.classList.remove("w-[calc(100vw-20px)]");
  workspace.classList.remove("md:w-[calc(100vw-40px)]");
  workspace.classList.remove("rd-12");
  workspace.style.width = "100svw";
  workspace.style.height = "100svh";

  // workspace.parentElement.style.margin = "0px";
  // workspace.parentElement.classList.remove("rd-12");
}

// const body = document.querySelector("body");
// const config = { attributes: true, childList: true, subtree: true };
// const observer = new MutationObserver((mutationRecords, observer) => {
//   for (const mutation of mutationRecords) {
//     if (mutation.addedNodes.length) {
//       const node = mutation.addedNodes.item(0);
//       if (node.textContent.includes("Create")) {
//         console.log(node);
//         node.querySelectorAll("div").forEach((item) => item.click());
//       }
//     }
//   }
// });
//
// observer.observe(body, config);
