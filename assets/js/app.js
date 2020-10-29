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
import { init as initGame } from "./game";
import { init as initInput } from "./input";
import { generateToken } from "./crypto";

const gameEl = document.getElementById("game");
const gameId = readGameIdFromURL();

const playerToken = generateToken();
document.playerToken = playerToken;

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
    document.state = state;
  });
}
