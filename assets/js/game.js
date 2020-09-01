import * as PIXI from "pixi.js";
import { isObject } from "lodash";

const addPlayerBunny = (app) => {
  // Create a new texture
  const texture = PIXI.Texture.from("images/bunny.png");

  const bunny = new PIXI.Sprite(texture);

  // Center bunny sprite in local bunny coordinates
  bunny.pivot.x = 12;
  bunny.pivot.y = 20;
  // bunny.pivot.x = Math.round(bunny.width / 2);
  // bunny.pivot.y = Math.round(bunny.height / 2);

  app.stage.addChild(bunny);

  // Move container to the center
  // bunny.x = app.screen.width / 2;
  // bunny.y = app.screen.height / 2;

  return bunny;
};

// Init app
const app = new PIXI.Application({
  width: 800,
  height: 600,
  backgroundColor: 0x1099bb,
  resolution: window.devicePixelRatio || 1,
});
document.getElementById("game").appendChild(app.view);

// Add bunny
const bunny = addPlayerBunny(app);

// OnClick - fire action
const onClick = (event) => {
  const sourceX = bunny.x;
  const sourceY = bunny.y;
  const targetX = event.data.global.x;
  const targetY = event.data.global.y;

  const dx = targetX - sourceX;
  const dy = targetY - sourceY;
  const dlength = Math.sqrt(dx * dx + dy * dy);

  if (dlength == 0) return;

  // Normalized direction vector
  const nx = dx / dlength;
  const ny = dy / dlength;

  const actionData = { type: "fire", x: nx, y: ny };
  document.channel.push("action", actionData, 10000);
};
app.renderer.plugins.interaction.on("pointerup", onClick);

// Draw projectiles
let projectiles = {};
const updateProjectiles = (data) => {
  for (const [id, projectile] of Object.entries(data)) {
    // console.log(id, projectile, projectiles[id]);
    // Update projectile
    if (projectiles[id] != null) {
      projectiles[id].x = projectile.x;
      projectiles[id].y = projectile.y;
      // Create projectile
    } else {
      const texture = PIXI.Texture.from("images/projectile_blue.png");
      const newPixiProjectile = new PIXI.Sprite(texture);
      newPixiProjectile.pivot.x = newPixiProjectile.width / 2;
      newPixiProjectile.pivot.y = newPixiProjectile.height / 2;
      app.stage.addChild(newPixiProjectile);
      projectiles[id] = newPixiProjectile;
      projectiles[id].x = projectile.x;
      projectiles[id].y = projectile.y;
    }
  }

  for (const [id, sprite] of Object.entries(projectiles)) {
    // Delete projectile
    if (data[id] == null) {
      projectiles[id].destroy();
      delete projectiles[id];
    }
  }
};

// Draw walls
let walls = {};
const updateWalls = (data) => {
  for (const [id, wall] of Object.entries(data)) {
    // Update
    if (walls[id] != null) {
      walls[id].x = wall.x;
      walls[id].y = wall.y;
      // Create
    } else {
      console.log("Creating wall");
      const texture = PIXI.Texture.from("images/wall_16.png");
      const sprite = new PIXI.Sprite(texture);
      sprite.pivot.x = sprite.width / 2;
      sprite.pivot.y = sprite.height / 2;
      app.stage.addChild(sprite);
      walls[id] = sprite;
      walls[id].x = wall.x;
      walls[id].y = wall.y;
    }
  }

  for (const [id, sprite] of Object.entries(walls)) {
    // Delete
    if (data[id] == null) {
      walls[id].destroy();
      delete walls[id];
    }
  }
};

// Listen for animate update
app.ticker.add((delta) => {
  if (document.state == undefined) {
    return;
  }
  bunny.x = document.state.x;
  bunny.y = document.state.y;

  updateProjectiles(document.state.projectiles);
  updateWalls(document.state.walls);
});
