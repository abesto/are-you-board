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
        var spec = Ludo.paths[side][pos.row][pos.column];
        if (spec === 'S') {
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
        var positions = [init];
        for (var i = 0; i < n; i++) {
            positions.push(Ludo.nextPosition(side, positions[positions.length - 1]));
        }
        positions.shift();
        return positions;
    }
};

Ludo.initialPositions[Ludo.Sides.red] = [
    Ludo.Pos(1, 1), Ludo.Pos(1, 2),
    Ludo.Pos(2, 1), Ludo.Pos(2, 2),
];
Ludo.initialPositions[Ludo.Sides.green] = [
    Ludo.Pos(1, 8), Ludo.Pos(1, 9),
    Ludo.Pos(2, 8), Ludo.Pos(2, 9),
];
Ludo.initialPositions[Ludo.Sides.yellow] = [
    Ludo.Pos(8, 8), Ludo.Pos(8, 9),
    Ludo.Pos(9, 8), Ludo.Pos(9, 9),
];
Ludo.initialPositions[Ludo.Sides.blue] = [
    Ludo.Pos(8, 1), Ludo.Pos(8, 2),
    Ludo.Pos(9, 1), Ludo.Pos(9, 2),
];

Ludo.paths[Ludo.Sides.red] = [
    '....ees....',
    '.SS.n.s....',
    '.SS.n.s....',
    '....n.s....',
    'eeeen.eeees',
    'eeee......s',
    'nwwww.swwww',
    '....n.s....',
    '....n.s....',
    '....n.s....',
    '....nww....'
];

Ludo.pathHead[Ludo.Sides.red] = Ludo.Pos(4, 0);
