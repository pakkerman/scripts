const data = process.argv[2];
const jsonData = JSON.parse(data);
// filter out checkpoint and default loras embedded by Civitai
const filteredJsonData = jsonData.filter(
  (item) =>
    !item.modelName.match(/Civitai/g) && !item.type.match(/checkpoint/g),
);

let output = "";
await main();
console.log(output);

async function main() {
  for (const data of filteredJsonData) {
    output += await parse(data);
    await sleep(100);
  }

  async function parse(data) {
    try {
      const { modelVersionId, weight } = data;
      const res = await fetch(
        `https://civitai.com/api/v1/model-versions/${modelVersionId}/`,
      );
      const json = await res.json();
      const name = json.files[0].name.replace(".safetensors", "");
      return `\n<lora:${name}:${weight}>,`;
    } catch (error) {
      console.log(error);
    }
  }
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
