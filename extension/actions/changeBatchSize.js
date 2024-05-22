function changeBatchSize(key) {
  if (key === "¡") {
    // alt + 1
    click(1);
  } else if (key === "™") {
    // alt + 2
    click(2);
  } else if (key === "£") {
    // alt + 3
    click(3);
  }

  function click(num) {
    document.querySelectorAll(".n-select.w-60")[0].querySelector("div").click();
    sleep(300);

    document.querySelectorAll("div.flex-c-sb.w-100")[num].click();
  }
}
