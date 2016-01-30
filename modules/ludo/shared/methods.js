Meteor.methods({
    "ludo/create": function () {
        return Games.insert({
            type: "ludo",
            nieces: []
        });
    },

    "ludo/addStartingPiecesForSide": function (id, side) {
        var newPieces = [];
        for (var i = 0; i < 4; i++) {
            newPieces.push({
                side: side,
                pos: {
                    row: Ludo.initialPositions[side][i].row,
                    column: Ludo.initialPositions[side][i].column
                }
            });
        }
        return Games.update(
            {type: "ludo", _id: id},
            {
                $push: {
                    pieces: {
                        $each: newPieces
                    }
                }
            }
        );
    },
    
    "ludo/move": function (gameId, row, column) {
        var game = Games.findOne({type: "ludo", _id: gameId});
        var i, piece;
        for (i = 0; i < game.pieces.length; i++) {
            if (game.pieces[i].pos.row === row && game.pieces[i].pos.column === column) {
                piece = game.pieces[i];
                break;
            }
        }
        var pieceKey = "pieces." + i;
        var updateOperation = {$set: {}};

        var newPos = Ludo.nextPositions(piece.side, piece.pos, game.dice).pop();

        if (newPos === null) {
            throw {error: "no-next-move", piece: piece};
        }
        updateOperation.$set[pieceKey] = {pos: newPos, side: piece.side};
        return Games.update(
            {type: "ludo", _id: gameId},
            updateOperation
        );
    }
});
