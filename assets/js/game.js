import * as PIXI from "pixi.js";
import sound from "pixi-sound";
import { Viewport } from "pixi-viewport";

const CONFIG = {
  tileSize: 32,
  screenWidth: 800,
  screenHeight: 600,
};

const FILES = {
  player: "/images/bunny.png",
  projectile: "/images/projectile_blue.png",
  wall: "/images/wall_16.png",
  zombie: "/images/zombie1_hold.png",
  exit: "/images/star.png",
  entry: "/images/coinSilver.png",
  tiles: {
    empty: "/images/tiles/empty.png",
    wall: "/images/tiles/wall.png",
  },
};

const SOUNDS = {
  // https://freesound.org/people/nsstudios/sounds/344276/
  fire: sound.Sound.from({
    url: "/sounds/344276__nsstudios__laser3.mp3",
    preload: true,
  }),
  // https://freesound.org/people/mwl500/sounds/54807/
  kick: sound.Sound.from({
    url: "/sounds/54807__mwl500__good-kick-in-the-head-sound.mp3",
    preload: true,
  }),
  // https://freesound.org/people/MisterKidX/sounds/454840/
  zombie_growl: sound.Sound.from({
    url: "/sounds/454840__misterkidx__zombie-thrown.mp3",
    preload: true,
  }),
};

const TEXT_STYLES = {
  hpBar: new PIXI.TextStyle({
    fontSize: 12,
  }),
};

export const processEffect = (effect) => {
  switch (effect.type) {
    case "fire":
      SOUNDS.fire.play();
      break;
    case "hit":
      SOUNDS.kick.play();
      break;
    case "zombie_attack":
      SOUNDS.zombie_growl.play();
      break;
    default:
      console.log("Uknown effect", effect);
  }
};

const addStatsText = (app) => {
  const basicText = new PIXI.Text("");
  basicText.x = 20;
  basicText.y = 20;
  app.stage.addChild(basicText);
  return basicText;
};

const coordsScreenToWorld = (viewport, screenCoords) => {
  const worldX =
    viewport.left +
    (screenCoords.x / CONFIG.screenWidth) * (viewport.right - viewport.left);

  const worldY =
    viewport.top +
    (screenCoords.y / CONFIG.screenHeight) * (viewport.bottom - viewport.top);

  return { x: worldX, y: worldY };
};

// OnClick - fire action
const onClick = (viewport, event) => {
  const sourceX = document.state.players[document.playerId].x;
  const sourceY = document.state.players[document.playerId].y;

  const worldCoords = coordsScreenToWorld(viewport, event.data.global);
  const targetX = worldCoords.x;
  const targetY = worldCoords.y;

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

const addSightRangeMarker = (container, sightRange) => {
  if (sightRange == null) return container;
  return addShapeMarker(container, ["circle", sightRange]);
};

const addShapeMarker = (container, shape) => {
  let marker = new PIXI.Graphics();

  if (shape[0] == "circle") {
    const size = shape[1];
    marker.lineStyle(1, 0xffbd01, 1);
    marker.beginFill(0xc34288, 0);
    marker.drawCircle(0, 0, size);
    marker.endFill();
  } else if (shape[0] == "rectangle") {
    const size = shape[1];
    marker.lineStyle(1, 0xffbd01, 1);
    marker.beginFill(0xc34288, 0);
    marker.drawRect(container.x - size / 2, container.y - size / 2, size, size);
    marker.endFill();
  }

  container.addChild(marker);
  container.marker = marker;

  return container;
};

const addHpBar = (container, hp, maxHp) => {
  if (hp == null || maxHp == null) {
    return container;
  }
  const hpBar = new PIXI.Text("" + hp + "/" + maxHp, TEXT_STYLES.hpBar);
  container.addChild(hpBar);
  container.hpBar = hpBar;

  return container;
};

const updateHpBar = (container, hp, maxHp) => {
  if (hp == null || maxHp == null) {
    return container;
  }

  container.hpBar.text = "" + hp + "/" + maxHp;
  return container;
};

const addSpriteTexture = (container, imgUrl) => {
  const texture = PIXI.Texture.from(imgUrl);
  let sprite = new PIXI.Sprite(texture);
  sprite.pivot.x = sprite.width / 2;
  sprite.pivot.y = sprite.height / 2;

  container.addChild(sprite);
  container.sprite = sprite;

  return container;
};

const updateSprites = (viewport, sprites, data, imgUrl) => {
  for (const [id, object] of Object.entries(data)) {
    // Update
    if (sprites[id] != null) {
      sprites[id].position.set(object.x, object.y);
      sprites[id] = updateHpBar(sprites[id], object.hp_current, object.hp_max);
      // Create
    } else {
      let container = new PIXI.Container();

      container = addSpriteTexture(container, imgUrl);
      container = addShapeMarker(container, object.shape);
      container = addSightRangeMarker(container, object.sight_range);
      container = addHpBar(container, object.hp_current, object.hp_max);

      viewport.addChild(container);
      sprites[id] = container;
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
  // Init app
  const app = new PIXI.Application({
    width: CONFIG.screenWidth,
    height: CONFIG.screenHeight,
    backgroundColor: 0x1099bb,
    resolution: window.devicePixelRatio || 1,
  });

  // Viewport
  const viewport = new Viewport({
    screenWidth: CONFIG.screenWidth,
    screenHeight: CONFIG.screenHeight,
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
    exits: {},
    entries: {},
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
    db.exits = updateSprites(
      viewport,
      db.exits,
      document.state.exits,
      FILES.exit
    );
    db.entries = updateSprites(
      viewport,
      db.entries,
      document.state.entries,
      FILES.entry
    );

    statsText.text =
      "" +
      document.state.stats.last_tick_ms +
      "ms\ntick: " +
      document.state.stats.tick;
  });

  app.renderer.plugins.interaction.on("pointerdown", (event) => {
    return onClick(viewport, event);
  });

  return app;
};
