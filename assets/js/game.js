import * as PIXI from "pixi.js";
import { isObject, wrap } from "lodash";
import { Viewport } from "pixi-viewport";

const CONFIG = {
  tileSize: 32,
};

const FILES = {
  player: "/images/bunny.png",
  projectile: "/images/projectile_blue.png",
  wall: "/images/wall_16.png",
  zombie: "/images/zombie1_hold.png",
  tiles: {
    empty: "/images/tiles/empty.png",
    wall: "/images/tiles/wall.png",
  },
};

const addStatsText = (app) => {
  const basicText = new PIXI.Text("");
  basicText.x = 20;
  basicText.y = 20;
  app.stage.addChild(basicText);
  return basicText;
};

// OnClick - fire action
const onClick = (event) => {
  const sourceX = document.state.players[document.playerId].x;
  const sourceY = document.state.players[document.playerId].y;

  const targetX = event.world.x;
  const targetY = event.world.y;

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

const updateSprites = (viewport, sprites, data, imgUrl) => {
  for (const [id, object] of Object.entries(data)) {
    // Update
    if (sprites[id] != null) {
      sprites[id].position.set(object.x, object.y);
      // Create
    } else {
      const texture = PIXI.Texture.from(imgUrl);
      let sprite = new PIXI.Sprite(texture);
      sprite.pivot.x = sprite.width / 2;
      sprite.pivot.y = sprite.height / 2;
      sprite = wrapWithSizeCircle(sprite, object.size);
      viewport.addChild(sprite);
      sprites[id] = sprite;
      sprites[id].position.set(object.x, object.y);
    }
  }

  // Delete
  for (const [id, sprite] of Object.entries(sprites)) {
    if (data[id] == null) {
      sprites[id].destroy();
      delete sprites[id];
    }
  }

  return sprites;
};

// Draw Tiles
const drawTiles = (app, tiles) => {
  let createdSprites = [];

  for (let x = 0; x < tiles.length; x++) {
    for (let y = 0; y < tiles[x].length; y++) {
      const tile = tiles[x][y];
      let texture = PIXI.Texture.from(FILES.tiles[tile]);
      let sprite = new PIXI.Sprite(texture);
      sprite.x = x * CONFIG.tileSize;
      sprite.y = y * CONFIG.tileSize;
      app.addChild(sprite);
      createdSprites.push(sprite);
    }
  }

  return createdSprites;
};

export const init = (gameEl) => {
  const screenWidth = 800;
  const screenHeight = 600;

  // Init app
  const app = new PIXI.Application({
    width: screenWidth,
    height: screenHeight,
    backgroundColor: 0x1099bb,
    resolution: window.devicePixelRatio || 1,
  });

  // Viewport
  const viewport = new Viewport({
    screenWidth: screenWidth,
    screenHeight: screenHeight,
    worldWidth: 1000,
    worldHeight: 1000,

    interaction: app.renderer.plugins.interaction, // the interaction module is important for wheel to work properly when renderer.view is placed or scaled
  });

  app.stage.addChild(viewport);

  viewport.wheel();

  gameEl.appendChild(app.view);

  // Add stats text
  const statsText = addStatsText(app);

  const db = {
    projectiles: {},
    walls: {},
    players: {},
    zombies: {},
  };

  // Add camera target
  const cameraTarget = new PIXI.Point(100, 200);
  viewport.follow(cameraTarget);

  const tiles = drawTiles(viewport, document.initState.tiles);

  // Listen for animate update
  app.ticker.add((delta) => {
    if (document.state == undefined) {
      //console.log("Cannot start PIXI app - document.state is undefined");
      return;
    }

    if (db.players[document.playerId] != null) {
      cameraTarget.x = db.players[document.playerId].x;
      cameraTarget.y = db.players[document.playerId].y;
    }

    db.players = updateSprites(
      viewport,
      db.players,
      document.state.players,
      FILES.player
    );
    db.projectiles = updateSprites(
      viewport,
      db.projectiles,
      document.state.projectiles,
      FILES.projectile
    );
    db.walls = updateSprites(
      viewport,
      db.walls,
      document.state.walls,
      FILES.wall
    );
    db.zombies = updateSprites(
      viewport,
      db.zombies,
      document.state.zombies,
      FILES.zombie
    );

    statsText.text =
      "" +
      document.state.stats.last_tick_ms +
      "ms\ntick: " +
      document.state.stats.tick;
  });

  viewport.on("clicked", onClick);

  return app;
};
