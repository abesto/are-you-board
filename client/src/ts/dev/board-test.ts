/// <reference path="../typings/tsd.d.ts"/>

import board = require("../shared/board");

var b = board.newLudoBoard();

$(() => {
    document.getElementById("container").appendChild(b.render());
    console.log("done");
});
