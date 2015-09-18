/// <reference path="typings/tsd.d.ts"/>

import board = require("./shared/Board");

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
    $board: JQuery;
    pieces: PieceMap;

    constructor(_board) {
        this.board = _board;
        this.pieces = new PieceMap();
    }

    getField(row, column): JQuery {
        return this.$board.find("td").filter(
            (_, field) => parseInt($(field).data("row"), 10) == row &&
                          parseInt($(field).data("column"), 10) == column);
    }

    render($container: JQuery) {
        this.$board = $("<table>").addClass(this.board.config.className);

        this.board.fields.forEach((row: Array<board.Field>, rowNum) => {
            const $row = $("<tr>");
            row.forEach((field: board.Field, columnNum) => $row.append(
                $("<td>")
                    .addClass(this.board.config.fieldTypeToCssClass[field.type])
                    .data({
                        row: rowNum,
                        column: columnNum
                    })
            ));
            this.$board.append($row);
        });

        this.board.pieces.forEach((piece: board.Piece) => {
            const $piece = $("<div>").text(piece.color);
            this.pieces.add(piece, $piece);
            this.getField(piece.field.row, piece.field.column).append($piece);
        });

        $container.children().remove();
        $container.append(this.$board)
    }
}

export = BoardView
