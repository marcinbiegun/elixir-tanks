// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//

import "phoenix_html";

import socket from "./socket";
import { consoleAppend, statusSet, readGameIdFromURL } from "./util";
import { init as initGame, processEffect } from "./game";
import { init as initInput } from "./input";
import { sendDebugAction } from "./admin_input";
import { generateToken } from "./crypto";

const gameEl = document.getElementById("game");
const gameId = readGameIdFromURL();

const playerToken = generateToken();
document.playerToken = playerToken;

const processEffects = (effects) => {
  effects.forEach((effect) => {
    processEffect(effect);
  });
};

if (gameEl != null && gameId != null) {
  console.log("Initializing game connection...");
  const channelId = `game:${gameId}`;
  //const channel = socket.channel(channelId);
  const params = { playerToken: playerToken };
  const channel = socket.channel(channelId, params);
  document.channel = channel;

  statusSet("game id", gameId);

  // Connect to game
  channel.join().receive("ok", (responsePayload) => {
    console.log("Connected to channel ${channelId}");
    console.log("Player ID " + responsePayload.player_id);

    consoleAppend(responsePayload.msg);

    document.playerId = responsePayload.player_id;
    document.initState = responsePayload.init_state;

    // Initialize systems
    initInput();
    initGame(gameEl);
  });

  // Setup state sync
  channel.on("tick", (state) => {
    processEffects(state.effect_events);
    document.state = state;
  });

  // Attach debug buttons
  document.getElementById("debug-next-map").onclick = () => {
    sendDebugAction("next_map");
  };
  document.getElementById("debug-restart-map").onclick = () => {
    sendDebugAction("restart_map");
  };
  document.getElementById("debug-restart-game").onclick = () => {
    sendDebugAction("restart_game");
  };
}
