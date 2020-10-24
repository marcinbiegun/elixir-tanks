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

  channel.join().receive("ok", (responsePayload) => {
    console.log(responsePayload, `ok response on channel join ${channelId}`);
    consoleAppend(responsePayload.msg);
    console.log("Setting player ID " + responsePayload.player_id);
    document.playerId = responsePayload.player_id;
  });
  channel.on("tick", (state) => {
    document.state = state;
  });

  initInput();
  initGame(gameEl);

  console.log("Connected to game " + gameId);
}
