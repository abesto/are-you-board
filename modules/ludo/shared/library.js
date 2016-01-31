Ludo = {
    initialPositions: {},
    paths: {},
    pathHead: {},

    Sides: {
        red: 'red',
        green: 'green',
        yellow: 'yellow',
        blue: 'blue'
    },

    Pos: function (row, column) {
        return {
            row: row,
            column: column
        };
    },

    nextPosition: function (side, pos) {
        if (!pos) {
            return pos;
        }
        var spec = Ludo.paths[side][pos.row][pos.column].toLowerCase();
        if (spec === 'i') {
            return Ludo.pathHead[side];
        } else if (spec === "e") {
            return {row: pos.row, column: pos.column + 1};
        } else if (spec === "n") {
            return {row: pos.row - 1, column: pos.column};
        } else if (spec === "s") {
            return {row: pos.row + 1, column: pos.column};
        } else if (spec === "w") {
            return {row: pos.row, column: pos.column - 1};
        } else {
            return null;
        }
    },

    nextPositions: function (side, init, n) {
        var positions = [Ludo.nextPosition(side, init)];
        if (positions[0] === Ludo.pathHead[side]) {
            return positions;
        }
        for (var i = 1; i < n; i++) {
            positions.push(Ludo.nextPosition(side, positions[positions.length - 1]));
        }
        return positions;
    },

    canMove: function (game, piece) {
        if (!game || !piece) { return false; }
        if (_.find(Ludo.initialPositions[piece.side], piece.pos) && game.dice !== 6) { return false; }
        var to = Ludo.nextPositions(piece.side, piece.pos, game.dice).pop();
        if (!to) { return false; }

        var pieceAtDest = _(game.pieces).find(function (piece) { return _(piece.pos).isEqual(to); });
        if (pieceAtDest && pieceAtDest.side === piece.side) { return false; }
        return true;
    },

    newPositionsIfMoved: function (game, piece) {
        var piecesAt = _(game.pieces).map('.pos'),
            pieceIndex = piecesAt.findIndex(piece.pos),
            retval = [];

        if (!Ludo.canMove(game, piece)) { return retval; }

        var path = Ludo.nextPositions(piece.side, piece.pos, game.dice);
        if (!path) { return retval; }

        var newPos = _.last(path);
        if (!newPos) { return retval; }

        retval.push({
            pieceIndex: pieceIndex,
            piece: game.pieces[pieceIndex],
            newPos: _.last(path),
            path: path
        });

        var takenPieceIndex = piecesAt.findIndex(newPos);
        if (takenPieceIndex === -1) {
            return retval;
        }
        var initialPositions = Ludo.initialPositions[game.pieces[takenPieceIndex].side];
        retval.push({
            pieceIndex: takenPieceIndex,
            piece: game.pieces[takenPieceIndex],
            newPos: _(initialPositions).find(function (pos) { return !piecesAt.find(pos); }),
            path: []
        });

        return retval;
    }
};

Ludo.paths[Ludo.Sides.red] = [
    '....ees....',
    '.ii.n.s....',
    '.ii.n.s....',
    '....n.s....',
    'Eeeen.eeees',
    'eeee......s',
    'nwwww.swwww',
    '....n.s....',
    '....n.s....',
    '....n.s....',
    '....nww....'
];
Ludo.paths[Ludo.Sides.green] = [
    '....esS....',
    '....nss.ii.',
    '....nss.ii.',
    '....nss....',
    'eeeen.eeees',
    'n.........s',
    'nwwww.swwww',
    '....n.s....',
    '....n.s....',
    '....n.s....',
    '....nww....'
];
Ludo.paths[Ludo.Sides.yellow] = [
    '....ees....',
    '....n.s....',
    '....n.s....',
    '....n.s....',
    'eeeen.eeees',
    'n......wwww',
    'nwwww.swwwW',
    '....n.s....',
    '....n.s.ii.',
    '....n.s.ii.',
    '....nww....'
];
Ludo.paths[Ludo.Sides.blue] = [
    '....ees....',
    '....n.s....',
    '....n.s....',
    '....n.s....',
    'eeeen.eeees',
    'n.........s',
    'nwwww.swwww',
    '....nns....',
    '.ii.nns....',
    '.ii.nns....',
    '....Nnw....'
];

_.each(Ludo.Sides, function (side) {
    var pathSpec = Ludo.paths[side];
    Ludo.initialPositions[side] = [];
    for (var rowIndex = 0; rowIndex < pathSpec.length; rowIndex++) {
        var row = pathSpec[rowIndex];
        for (var columnIndex = 0; columnIndex < row.length; columnIndex++) {
            var spec = row[columnIndex];
            if (spec === 'i') {
                Ludo.initialPositions[side].push(Ludo.Pos(rowIndex, columnIndex));
            } else if (_.indexOf('NESW', spec) > -1) {
                if (Ludo.pathHead[side]) {
                    throw "Path head for " + side + " is already defined. Old is row=" + Ludo.pathHead[side].row + " column=" + Ludo.pathHead[side].column + ", new is row=" + rowIndex + " column=" + columnIndex + " for spec=" + spec;
                }
                Ludo.pathHead[side] = Ludo.Pos(rowIndex, columnIndex);
            }
        }
    }
});
