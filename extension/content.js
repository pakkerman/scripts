// one click download
// click reaction buttons
// const buttons = [... document.querySelectorAll('.mantine-UnstyledButton-root.mantine-Button-root')]
// buttons.filter(item => item.querySelector('span').textContent === '👍0').forEach(item=> item.click())
// buttons.filter(item => item.querySelector('span').textContent === '❤️0').forEach(item=> item.click())

const domain = "https://tusi.cn";

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  console.log(`\naction: ${message.action} received\n`);
  switch (message.action) {
    case "run":
      run();
      break;

    case "generate":
      clickGenerate();
      break;

    case "download":
      download();
      break;

    case "createProject":
      const location = window.location.href;
      if (location === `${domain}/new/project`) {
        createProject();
      } else if (/https\:\/\/tusi.cn\/new\/model./.test(location)) {
        createModel();
      }
      break;

    default:
      return;
  }
});

function clickGenerate() {
  document.querySelectorAll("button").forEach((item) =>
    item.querySelectorAll("*").forEach((subitem) => {
      if (subitem?.textContent === "在线生成") subitem.click();
    }),
  );
}

const upscalerFields = {
  高清修复采样次数: 15,
  重绘噪声强度: 0.35,
  采样次数: 1,
  "提示词相关性(CFG Scale)": 7,
  models: ["DPM++ SDE Karras", "R-ESRGAN 4x+ Anime6B"],
};

const ADtailerFields = {
  重绘噪声强度: 0.35,
  采样次数: 10,
  "提示词相关性(CFG Scale)": 7,
  models: ["face_yolov8n_v2.pt", "DPM++ SDE Karras"],
};

function run() {
  hideViolationSpan();
  addEventToDeleteButton();
  expendTextAreas();

  const pane = document.querySelectorAll('.n-tab-pane:not([class*=" "])');
  let selectedPane = "";
  pane.forEach((item) => {
    if (item.style.display != "") return;
    selectedPane = item.querySelector("h3").textContent;
  });

  // expend upscaler and Adetailer
  document
    .querySelectorAll("div.n-switch__rail")
    .forEach((item) => item.click());
  // click the same seed number
  document.querySelectorAll("span.c-main.cursor-pointer")[0].click();

  toggleOpenMoreSettings();
  if (selectedPane === "高清修复") {
    fillfields(upscalerFields);
    selectModels(upscalerFields.models);
  } else if (selectedPane === "ADetailer") {
    fillfields(ADtailerFields);
    selectModels(ADtailerFields.models);
  }
}

function selectModels(models) {
  const dropdowns = document.querySelectorAll(".n-select");
  click();
  setTimeout(click, 500);

  function click() {
    dropdowns.forEach((element) => {
      const clickable = element.querySelector("div");
      clickable.click();
    });
  }

  setTimeout(() => {
    const options = document.querySelectorAll(".n-base-select-option__content");
    options.forEach((option) => {
      if (models.includes(option.textContent)) option.click();
    });
  }, 1000);
}

function fillfields(fields) {
  const inputEvent = new Event("input", { bubbles: true });
  const labels = document.querySelectorAll("label");
  labels.forEach((element) => {
    const span = element.querySelector("span");
    if (!span) return;

    const innerSpan = span.querySelector("span");
    const field = span.textContent ?? innerSpan.textContent;
    if (field) {
      const value = fields[field];
      if (!field || value == null) return;

      const input = element.parentElement.querySelector("input");

      input.value = String(value);
      input.dispatchEvent(inputEvent);
    }
  });
}

function toggleOpenMoreSettings() {
  const toggle = document.querySelectorAll('[icon-id="arrowup"]');
  toggle.forEach((item) => {
    if (!item.classList.contains("rotate-180")) item.click();
  });
}

function hideViolationSpan() {
  // hide span
  document.querySelectorAll("span").forEach((item) => {
    if (item.classList.value.includes("c-#E88080"))
      item.classList.add("hidden");
  });
}

function expendTextAreas() {
  const textareas = [...document.querySelectorAll("textarea")];
  textareas.forEach((item) => (item.rows = 15));
}

const confirmButtonObserver = new MutationObserver(() => {
  const elements = document.querySelectorAll("span.n-button__content");
  elements[1].click();
  confirmButtonObserver.disconnect();
});

function addEventToDeleteButton() {
  document.querySelectorAll("[icon-id=delete").forEach((item) => {
    item.addEventListener("click", () => {
      confirmButtonObserver.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: true,
        childList: true,
        characterData: true,
      });
    });
  });
}

function download() {
  console.log("clicked download");
  const items = document.querySelectorAll(
    "[icon-id=download]:not(.vi-button__icon__size)",
  );
  items.forEach((item, idx) => {
    setTimeout(() => {
      item.click();
      console.log(`downloading: ${idx + 1} / ${items.length}`);
    }, 500 * idx);
  });
}

async function createProject() {
  const [id] = await getIdFromClipboard();
  if (isNaN(+id)) return;

  const res = await fetch(`https://civitai.com/api/v1/models/${id}`);
  const data = await res.json();
  const { name, type } = data;

  const inputs = document.querySelectorAll(".n-input__input-el");
  inputs[0].value = String(name);
  inputs[0].dispatchEvent(
    new Event("input", { bubbles: true, data: inputs[0].value }),
  );

  const optionBox = document.querySelectorAll(".n-base-selection-label")[0];
  optionBox.click();

  await sleep(500);
  const option = [
    ...document.querySelectorAll(".n-base-select-option__content"),
  ].filter((item) => item.textContent.toLowerCase() === type.toLowerCase());
  option[0].click();

  const tags = document.querySelectorAll(
    ".n-tag.__tag-dark-1mkpae0-dmc.cursor-pointer.opacity-75",
  );

  tags[2].click();
  tags[5].click();

  document.querySelectorAll(".n-radio-input")[3].click();

  await sleep(500);
  const input = document.querySelectorAll(".n-input__input-el")[1];
  input.value = String(`https://civitai.com/models/${id}`);
  input.dispatchEvent(new Event("input", { bubbles: true, data: input.value }));

  await sleep(500);
  // click create
  const createButton = document.querySelector(
    ".vi-button.vi-button--size-medium.vi-button--type-primary",
  );

  createButton.click();
}

async function createModel() {
  const [id, versionId] = await getIdFromClipboard();
  console.log("with id:", id);

  if (isNaN(+id)) return;
  let target = `https://civitai.com/api/v1/models/${id}`;
  if (versionId) {
    target = `https://civitai.com/api/v1/model-versions/${versionId}`;
  }

  const res = await fetch(target);
  const data = await res.json();
  const inputEvent = new Event("input", { bubbles: true });
  const keyEvent = new KeyboardEvent("keydown", {
    key: "r",
    bubbles: true,
    cancelable: true,
  });
  const inputs = [...document.querySelectorAll("input.n-input__input-el")];

  // fill name
  inputs[0].value = data.modelVersions?.[0].name || data.name;
  inputs[0].dispatchEvent(inputEvent);

  // fill trigger words
  const trainedWords =
    data.modelVersions?.[0].trainedWords ||
    data.trainedWords.join(",").split(",").join(",\n");

  const textarea = document.querySelectorAll("textarea.n-input__textarea-el");
  textarea[0].value = trainedWords;
  textarea[0].dispatchEvent(inputEvent);

  let div = document.querySelector(
    "div.n-space.n-dynamic-tags.__dynamic-tags-dark-1mkpae0",
  );
  const button = div.querySelector(
    "button.__button-dark-1mkpae0-alsmd.n-button.n-button--default-type.n-button--small-type.n-button--dashed",
  );
  button.click();

  setTimeout(() => {
    div = document.querySelector(
      "div.n-space.n-dynamic-tags.__dynamic-tags-dark-1mkpae0",
    );
    const input = div.querySelector("input");
    console.log(input);
    input.focus();
    const textToEnter = "r";
    for (let i = 0; i < textToEnter.length; i++) {
      const event = new KeyboardEvent("keypress", { key: textToEnter[i] });
      input.dispatchEvent(event);
    }
  }, 500);
}

async function sleep(ms) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve();
    }, ms);
  });
}

async function getIdFromClipboard() {
  const id = await navigator.clipboard.readText();

  return id.match(/\d{2,8}/g);
}
