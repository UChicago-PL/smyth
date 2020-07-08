"use strict";

let cmConfig = {
  viewportMargin: Infinity,
  lineNumbers: true,
  theme: "base16-dark"
}

// Source: https://plainjs.com/javascript/manipulation/wrap-an-html-structure-around-an-element-28/
function wrap(el, wrapper) {
  el.parentNode.insertBefore(wrapper, el);
  wrapper.appendChild(el);
}

function holeBinding(container, name, expression) {
  let bindingEl = document.createElement("div");
  bindingEl.className = "binding";

  let nameEl = document.createElement("div");
  nameEl.className = "name";
  nameEl.innerHTML = "??<span>" + name + "</span>"
  bindingEl.appendChild(nameEl);

  let mapsEl = document.createElement("div");
  mapsEl.className = "mapsto";
  mapsEl.innerHTML = "↦";
  bindingEl.appendChild(mapsEl);

  let expEl = document.createElement("div");
  expEl.className = "expression";

  let expTextArea = document.createElement("textarea");
  expTextArea.value = expression;
  expTextArea.readonly = true;
  expEl.appendChild(expTextArea);

  bindingEl.appendChild(expEl);

  container.appendChild(bindingEl);

  CodeMirror.fromTextArea(expTextArea, {
    ...cmConfig,
    readOnly: true
  });
}

window.onload = function() {
  var smythBlocks = document.getElementsByClassName("smyth");
  for (var i = 0; i < smythBlocks.length; i++) {
    let smythBlock = smythBlocks.item(i);

    let inputArea = document.createElement("div");
    inputArea.className = "input";

    let inputTextArea = smythBlock.getElementsByTagName("textarea")[0];
    wrap(inputTextArea, inputArea);

    let inputCm = CodeMirror.fromTextArea(inputTextArea, cmConfig);

    let outputArea = document.createElement("div");
    outputArea.className = "output";
    outputArea.style = "--output-height: 0px;"

    let forgeButton = document.createElement("button");
    forgeButton.className = "forge";
    forgeButton.textContent = "Forge ▸"
    forgeButton.addEventListener("click", function() {
      outputArea.textContent = "";

      let result = JSON.parse(Smyth.forge(inputCm.getValue()));

      for (const hole in result) {
        holeBinding(outputArea, hole, result[hole]);
      }

      // let clearButton = document.createElement("button");
      // clearButton.className = "clear-forge";
      // clearButton.textContent = "Clear Results";

      outputArea.style = "--output-height: auto;";
      outputArea.style = "--output-height: " + outputArea.clientHeight + "px;";
    });

    smythBlock.appendChild(forgeButton);
    smythBlock.appendChild(outputArea);
  }
}
