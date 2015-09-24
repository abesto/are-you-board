interface Dictionary<T> {
    [index: string]: T;
}

interface BoardConfiguration {
    shape: string
    charToFieldType: Dictionary<number>
}

class Vector {
    row: number;
    column: number;
    constructor(row, column) {
        this.row = row;
        this.column = column;
    }
}

export enum PieceColor { GREEN, YELLOW, RED, BLUE}
export class Piece {
    color: PieceColor;
    field: Field;

    constructor(color) {
        this.color = color;
    }

    put(field: Field) {
        if (field.piece) {
            throw `Target field ${field} not empty`;
        }
        if (this.field) {
            this.field.piece = null;
        }
        this.field = field;
        this.field.piece = this;
    }
}

export const LudoPath = {
    vectorForPiece: (() => {
        const map = `
....eEs....
....nss....
....nss....
....nss....
eeeen.eeees
Neee...wwwS
nwwww.swwww
....nns....
....nns....
....nns....
....nWw....`.trim();

        function ifPieceColor(color, then, otherwise) {
            return (piece:Piece) => {
                if (color === piece.color) {
                    return then();
                } else {
                    return otherwise();
                }
            };
        }

        const vectorFactory = {
            "e": () => new Vector(0, 1),
            "s": () => new Vector(1, 0),
            "w": () => new Vector(0, -1),
            "n": () => new Vector(-1, 0),
            ".": () => new Vector(0, 0)
        };
        vectorFactory["E"] = ifPieceColor(PieceColor.GREEN, vectorFactory.s, vectorFactory.e);
        vectorFactory["S"] = ifPieceColor(PieceColor.YELLOW, vectorFactory.w, vectorFactory.s);
        vectorFactory["W"] = ifPieceColor(PieceColor.BLUE, vectorFactory.n, vectorFactory.w);
        vectorFactory["N"] = ifPieceColor(PieceColor.RED, vectorFactory.e, vectorFactory.n);

        return map.split("\n").map((line, row) =>
            line.split("").map((char, column) =>
                vectorFactory[char]
            )
        );
    })(),

    moveOne: (piece: Piece) => {
        const vector = LudoPath.vectorForPiece[piece.field.row][piece.field.column](piece);
        const newField = piece.field.board.fields
            [piece.field.row + vector.row]
            [piece.field.column + vector.column];
        if (newField == piece.field) {
            throw "Trying to move to the same field";
        }
        piece.put(newField);
    },

    move: (piece: Piece, n: number) => {
        for (var i = 0; i < n; i++) {
            LudoPath.moveOne(piece);
        }
    }
};

export enum LudoFieldType { BLANK, WHITE, GREEN, YELLOW, RED, BLUE, BLACK }
const LudoBoardConfiguration: BoardConfiguration = {
    shape: `
....www....
....wgw....
....wgw....
....wgw....
wwwwwgwwwww
wrrrrByyyyw
wwwwwbwwwww
....wbw....
....wbw....
....wbw....
....www....`.trim(),

    charToFieldType:
    {
        "w": LudoFieldType.WHITE,
        "g": LudoFieldType.GREEN,
        "y": LudoFieldType.YELLOW,
        "b": LudoFieldType.BLUE,
        "r": LudoFieldType.RED,
        "B": LudoFieldType.BLACK,
        ".": LudoFieldType.BLANK
    },
};


export class Field {
    type: number;
    piece: Piece;
    board: Board;
    row: number;
    column: number;

    constructor(type, row, column) {
        this.type = type;
        this.row = row;
        this.column = column;
    }
}

export class Board {
    fields: Array<Array<Field>>;
    pieces: Array<Piece>;
    config: BoardConfiguration;

    constructor(fields: Array<Array<Field>>, config: BoardConfiguration) {
        this.fields = fields;
        this.config = config;
        this.fields.forEach((row: Array<Field>) => row.forEach((field: Field) => field.board = this));
        this.pieces = [];
    }

    addPiece(piece: Piece, row, column) {
        piece.put(this.fields[row][column]);
        this.pieces.push(piece);
    }
}

function buildBoard(config: BoardConfiguration): Board {
    var fields: Array<Array<Field>> = [[]];

    for (var i = 0; i < config.shape.length; i++) {
        var char = config.shape[i];
        if (char == '\n') {
            fields.push([]);
        } else if (char in config.charToFieldType) {
            var row = fields.length - 1;
            var column = fields[row].length;
            fields[row].push(
                new Field(config.charToFieldType[char], row, column)
            );
        } else {
            throw `OH NOES, it's a ${char}!`;
        }
    }
    return new Board(fields, config);
}

export function newLudoBoard() {
    return buildBoard(LudoBoardConfiguration);
}
