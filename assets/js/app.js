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

const gameId = 123;
const channel = socket.channel(`game:${gameId}`);
channel.join().receive("ok", (responsePayload) => {
  console.log(responsePayload, "response from channel join");
});
