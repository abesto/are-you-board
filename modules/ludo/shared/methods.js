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
        var game = Games.findOne({type: "ludo", _id: gameId}),
            piece = _(game.pieces).find({pos: {row: row, column: column}}),
            newPositions = Ludo.newPositionsIfMoved(game, piece);

        var updateOperation = {$set: {}};
        _.each(newPositions, function (spec) {
            updateOperation.$set["pieces." + spec.pieceIndex + ".pos"] = spec.newPos;
        });

        return Games.update(
            {type: "ludo", _id: gameId},
            updateOperation
        );
    }
});
