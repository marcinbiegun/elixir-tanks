import * as PIXI from "pixi.js";

const app = new PIXI.Application({
  width: 800,
  height: 600,
  backgroundColor: 0x1099bb,
  resolution: window.devicePixelRatio || 1,
});
document.getElementById("game").appendChild(app.view);

// Create a new texture
const texture = PIXI.Texture.from("images/bunny.png");

const bunny = new PIXI.Sprite(texture);
app.stage.addChild(bunny);

// Move container to the center
bunny.x = app.screen.width / 2;
bunny.y = app.screen.height / 2;

// Center bunny sprite in local bunny coordinates
bunny.pivot.x = bunny.width / 2;
bunny.pivot.y = bunny.height / 2;

// Listen for animate update
app.ticker.add((delta) => {
  if (document.state == undefined) {
    return;
  }
  bunny.x = document.state.x;
  bunny.y = document.state.y;
});
