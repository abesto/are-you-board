/// <reference path="../typings/tsd.d.ts"/>
/// <reference path="../../../../shared/Board.ts"/>

var b = newLudoBoard();

$(() => {
    document.getElementById("container").appendChild(b.render());
});
