/// <reference path="../typings/tsd.d.ts"/>

import board = require("../shared/Board");
import IBoardViewConfiguration = require("./IBoardViewConfiguration");

const PieceColorMap = {};
PieceColorMap[board.PieceColor.BLUE] = "blue";

class PieceMapItem {
    piece: board.Piece;
    $el: JQuery;

    constructor(piece, $el) {
        this.piece = piece;
        this.$el = $el;
    }
}

class PieceMap {
    items: Array<PieceMapItem>;

    constructor() {
        this.items = [];
    }

    add(piece, $el) {
        this.items.push(new PieceMapItem(piece, $el));
    }

    get(piece): JQuery {
        for (var i = 0; i < this.items.length; i++) {
            if (this.items[i].piece == piece) {
                return this.items[i].$el;
            }
        }
        throw "No such piece";
    }
}

class BoardView {
    board: board.Board;
    config: IBoardViewConfiguration;
    $board: JQuery;
    pieces: PieceMap;

    constructor(_board: board.Board, config: IBoardViewConfiguration) {
        this.board = _board;
        this.pieces = new PieceMap();
        this.config = config;
    }

    getField(row, column): JQuery {
        return this.$board.find("td").filter(
            (_, field) => parseInt($(field).data("row"), 10) == row &&
                          parseInt($(field).data("column"), 10) == column);
    }

    render($container: JQuery) {
        this.$board = $("<table>").addClass(this.config.boardClassName);

        this.board.fields.forEach((row: Array<board.Field>, rowNum) => {
            const $row = $("<tr>");
            row.forEach((field: board.Field, columnNum) => $row.append(
                $("<td>")
                    .addClass(this.config.fieldTypeToCssClass[field.type])
                    .data({
                        row: rowNum,
                        column: columnNum
                    })
            ));
            this.$board.append($row);
        });

        this.board.pieces.forEach((piece: board.Piece) => {
            const $piece = $("<div>").addClass(`${this.config.pieceClassName} ${this.config.pieceColorToCssClass[piece.color]}`);
            this.pieces.add(piece, $piece);
            this.getField(piece.field.row, piece.field.column).append($piece);
        });

        $container.children().remove();
        $container.append(this.$board)
    }
}

export = BoardView
