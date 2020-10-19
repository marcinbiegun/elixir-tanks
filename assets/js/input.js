import { isEqual } from "lodash";

const gameId = 123;

const keyCodeS = 83;
const keyCodeA = 65;
const keyCodeD = 68;
const keyCodeW = 87;
const keyCodeLeft = 37;
const keyCodeRight = 39;
const keyCodeUp = 38;
const keyCodeDown = 40;
const keyCodeSpace = 32;

export const init = () => {
  document.input = {
    left: false,
    right: false,
    up: false,
    down: false,
  };

  document.addEventListener("keydown", function (event) {
    switch (event.keyCode) {
      case keyCodeS:
        event.preventDefault();
        updateInput({ down: true });
        break;
      case keyCodeA:
        event.preventDefault();
        updateInput({ left: true });
        break;
      case keyCodeD:
        event.preventDefault();
        updateInput({ right: true });
        break;
      case keyCodeW:
        event.preventDefault();
        updateInput({ up: true });
        break;
      case keyCodeSpace:
        break;
    }
  });

  document.addEventListener("keyup", function (event) {
    event.preventDefault();
    switch (event.keyCode) {
      case keyCodeS:
        updateInput({ down: false });
        break;
      case keyCodeA:
        updateInput({ left: false });
        break;
      case keyCodeD:
        updateInput({ right: false });
        break;
      case keyCodeW:
        updateInput({ up: false });
        break;
      case keyCodeSpace:
        break;
    }
  });

  const updateInput = (update) => {
    const newInput = Object.assign(Object.assign({}, document.input), update);
    if (isEqual(document.input, newInput)) {
      return;
    }
    document.lastInput = document.input;
    document.input = newInput;
    document.channel.push("input", document.input, 10000);
  };
};

// .receive("ok", (msg) => console.log("created message", msg) )
// .receive("error", (reasons) => console.log("create failed", reasons) )
// .receive("timeout", () => console.log("Networking issue...") )
