import * as PIXI from "pixi.js";
import { isObject } from "lodash";

const playerId = 0;

const FILES = {
  player: "images/bunny.png",
  projectile: "images/projectile_blue.png",
  wall: "images/wall_16.png",
  zombie: "images/zombie1_hold.png",
};

const addStatsText = (app) => {
  const basicText = new PIXI.Text("");
  basicText.x = 20;
  basicText.y = 20;
  app.stage.addChild(basicText);
  return basicText;
};

// Init app
const app = new PIXI.Application({
  width: 800,
  height: 600,
  backgroundColor: 0x1099bb,
  resolution: window.devicePixelRatio || 1,
});
document.getElementById("game").appendChild(app.view);

// Add stats text
const statsText = addStatsText(app);

// OnClick - fire action
const onClick = (event) => {
  const sourceX = document.state.players[playerId].x;
  const sourceY = document.state.players[playerId].y;
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
      const texture = PIXI.Texture.from(FILES.projectile);
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
      let texture = PIXI.Texture.from(FILES.wall);
      let sprite = new PIXI.Sprite(texture);
      sprite.pivot.x = sprite.width / 2;
      sprite.pivot.y = sprite.height / 2;
      sprite = wrapWithSizeCircle(sprite, wall.size);
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

// Draw players
let players = {};
const updatePlayers = (data) => {
  for (const [id, player] of Object.entries(data)) {
    // Update
    if (players[id] != null) {
      players[id].x = player.x;
      players[id].y = player.y;
      // Create
    } else {
      console.log("Creating player");
      let texture = PIXI.Texture.from(FILES.player);
      let sprite = new PIXI.Sprite(texture);
      sprite.pivot.x = 12;
      sprite.pivot.y = 20;
      sprite = wrapWithSizeCircle(sprite, player.size);
      app.stage.addChild(sprite);
      players[id] = sprite;
      players[id].x = player.x;
      players[id].y = player.y;
    }
  }

  for (const [id, sprite] of Object.entries(players)) {
    // Delete
    if (data[id] == null) {
      players[id].destroy();
      delete players[id];
    }
  }
};

const wrapWithSizeCircle = (object, size) => {
  let sizeCircle = new PIXI.Graphics();
  sizeCircle.lineStyle(1, 0xffbd01, 1);
  sizeCircle.beginFill(0xc34288, 0);
  sizeCircle.drawCircle(0, 0, size);
  sizeCircle.endFill();

  let container = new PIXI.Container();
  container.addChild(sizeCircle);
  container.addChild(object);

  return container;
};

// Draw zombies
let zombies = {};
const updateZombies = (data) => {
  for (const [id, zombie] of Object.entries(data)) {
    // Update
    if (zombies[id] != null) {
      zombies[id].x = zombie.x;
      zombies[id].y = zombie.y;
      // Create
    } else {
      console.log("Creating zombie");
      let texture = PIXI.Texture.from(FILES.zombie);
      let sprite = new PIXI.Sprite(texture);
      sprite.pivot.x = sprite.width / 2;
      sprite.pivot.y = sprite.height / 2;
      sprite = wrapWithSizeCircle(sprite, zombie.size);
      app.stage.addChild(sprite);
      zombies[id] = sprite;
      zombies[id].x = zombie.x;
      zombies[id].y = zombie.y;
    }
  }

  for (const [id, sprite] of Object.entries(zombies)) {
    // Delete
    if (data[id] == null) {
      zombies[id].destroy();
      delete zombies[id];
    }
  }
};

// Listen for animate update
app.ticker.add((delta) => {
  if (document.state == undefined) {
    return;
  }

  updatePlayers(document.state.players);
  updateProjectiles(document.state.projectiles);
  updateWalls(document.state.walls);
  updateZombies(document.state.zombies);

  statsText.text =
    "" +
    document.state.stats.last_tick_ms +
    "ms\ntick: " +
    document.state.stats.tick;
});
