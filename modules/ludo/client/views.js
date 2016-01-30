var boardDef = [
    '....www....',
    '....wgw....',
    '....wgw....',
    '....wgw....',
    'wwwwwgwwwww',
    'wrrrrByyyyw',
    'wwwwwbwwwww',
    '....wbw....',
    '....wbw....',
    '....wbw....',
    '....www....'
];

var fieldClasses = {
    '.': '',
    'w': 'path',
    'r': 'path red',
    'g': 'path green',
    'y': 'path yellow',
    'b': 'path blue',
    'B': 'path black'
};

Template.LudoBoard.helpers({
    rows: function () {
        var game = this.game;
        var rows = [];
        var i, j;
        for (i = 0; i < 11; i++) {
            var row = {fields: []};
            for (j = 0; j < 11; j++) {
                row.fields.push({row: i, column: j, piece: null, ghost: null});
            }
            rows.push(row);
        }
        for (i = 0; i < game.pieces.length; i++) {
            var piece = game.pieces[i];
            rows[piece.pos.row].fields[piece.pos.column].piece = piece;
        }
        var ghost = Session.get("ludo/ghost");
        console.log(ghost);
        if (ghost) {
            rows[ghost.pos.row].fields[ghost.pos.column].ghost = ghost;
        }
        return rows;
    }
});

Template.LudoField.helpers({
    fieldClasses: function () {
        var fieldDef = boardDef[this.row][this.column];
        return fieldClasses[fieldDef];
    }
});

Template.LudoHintText.helpers({
    hintText: function () {
        var hints = Session.get("ludo/hints");
        if (hints) {
            return hints[this.row + "," + this.column];
        }
        return '';
    }
});
