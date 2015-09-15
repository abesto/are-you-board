interface Dictionary<T> {
    [index: string]: T;
}

interface NumberIndexedDictionary<T> {
    [index: number]: T
}

interface BoardConfiguration {
    className: string
    shape: string
    charToFieldType: Dictionary<number>
    fieldTypeToCssClass: NumberIndexedDictionary<string>
}

enum LudoFieldType { BLANK, WHITE, GREEN, YELLOW, RED, BLUE, BLACK }
const LudoBoardConfiguration: BoardConfiguration = {
    className: "ludo-board",

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

    fieldTypeToCssClass: {}
};
LudoBoardConfiguration.fieldTypeToCssClass[LudoFieldType.WHITE] = 'white';
LudoBoardConfiguration.fieldTypeToCssClass[LudoFieldType.GREEN] = 'green';
LudoBoardConfiguration.fieldTypeToCssClass[LudoFieldType.YELLOW] = 'yellow';
LudoBoardConfiguration.fieldTypeToCssClass[LudoFieldType.BLUE] = 'blue';
LudoBoardConfiguration.fieldTypeToCssClass[LudoFieldType.RED] = 'red';
LudoBoardConfiguration.fieldTypeToCssClass[LudoFieldType.BLACK] = 'black';
LudoBoardConfiguration.fieldTypeToCssClass[LudoFieldType.BLANK] = 'blank';


enum PieceColor { GREEN, YELLOW, RED, BLUE}
class Piece {
    color: PieceColor;
}

class Field {
    type: number;
    piece: Piece;

    constructor(type: number) {
        this.type = type;
    }
}


class Board {
    fields: Array<Array<Field>>;
    config: BoardConfiguration;

    constructor(fields: Array<Array<Field>>, config: BoardConfiguration) {
        this.fields = fields;
        this.config = config;
    }

    render(): HTMLTableElement {
        const table = document.createElement("table");
        table.className = this.config.className;
        this.fields.forEach((row: Array<Field>) => {
            const tableRow = document.createElement("tr");
            row.forEach((field: Field) => {
                const tableField = document.createElement("td");
                tableField.innerHTML = field.type.toString();
                tableField.className = this.config.fieldTypeToCssClass[field.type];
                tableRow.appendChild(tableField);
            });
            table.appendChild(tableRow);
        });
        return table;
    }
}

function buildBoard(config: BoardConfiguration): Board {
    var fields: Array<Array<Field>> = [[]];
    for (var i = 0; i < config.shape.length; i++) {
        var char = config.shape[i];
        if (char == '\n') {
            fields.push([]);
        } else if (char in config.charToFieldType) {
            fields[fields.length - 1].push(
                new Field(config.charToFieldType[char])
            );
        } else {
            throw `OH NOES, it's a ${char}!`;
        }
    }
    return new Board(fields, config);
}

function newLudoBoard() {
    return buildBoard(LudoBoardConfiguration);
}
