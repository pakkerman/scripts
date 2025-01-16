const data = process.argv[2];
const jsonData = JSON.parse(data);
// filter out checkpoint and default loras embedded by Civitai
const filteredJsonData = jsonData.filter(
  (item) =>
    !item.modelName.match(/Civitai/g) && !item.type.match(/checkpoint/g),
);

let output = "";
const count = filteredJsonData.length;
let currCount = 0;
filteredJsonData.forEach(async (data) => {
  try {
    const { modelVersionId, weight } = data;
    const res = await fetch(
      `https://civitai.com/api/v1/model-versions/${modelVersionId}/`,
    );
    const json = await res.json();
    const name = json.files[0].name.replace(".safetensors", "");
    output += `<lora:${name}:${weight}>,\n`;
    currCount++;
  } catch (error) {
    console.log(error);
  }
  await sleep(100);

  if (currCount === count) {
    console.log(output);
  }
});

// "<lora:" +
// modelFileName.replace(".safetensors", "") +
// ":" +
// ressource.weight +
// ">, #" +
// url +
// " #" +
// modelName +
// "\n ";
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
