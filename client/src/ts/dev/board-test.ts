/// <reference path="../typings/tsd.d.ts"/>

import board = require("../shared/board");
import BoardView = require("../board-view/BoardView");
import boardViewConfig = require("../board-view/LudoBoardViewConfiguration");

$(() => {
    var v;
    var b = board.newLudoBoard();

    b.addPiece(new board.Piece(board.PieceColor.RED), 4, 0);
    b.addPiece(new board.Piece(board.PieceColor.GREEN), 0, 6);
    b.addPiece(new board.Piece(board.PieceColor.YELLOW), 6, 10);
    b.addPiece(new board.Piece(board.PieceColor.BLUE), 10, 4);

    v = new BoardView(b, boardViewConfig);

    v.render($("#container"));

    setInterval(() => {
        b.pieces.forEach((piece) => board.LudoPath.moveOne(piece));
        v.render($("#container"));
    }, 200)
});
