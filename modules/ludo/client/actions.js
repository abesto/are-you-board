function clearGhostAndHints() {
    Session.set("ludo/ghosts", null);
    Session.set("ludo/hints", null);
}

Template.LudoField.events({
    "click .piece": function (event, template) {
        Meteor.call("ludo/move", template.parent(2).data.game._id, this.row, this.column);
        clearGhostAndHints();
    },

    "mouseenter .piece.can-move": function (event, template) {
        var game = template.parent(2).data.game,
            newPositions = Ludo.newPositionsIfMoved(game, this.piece);

        Session.set("ludo/ghosts", newPositions.map(function (spec) {
            return {
                side: spec.piece.side,
                pos: spec.newPos
            };
        }));

        var hints = {};
        _.each(newPositions, function (spec) {
            _.each(spec.path, function (pos, index) {
                hints[pos.row + "," + pos.column] = index + 1;
            });
        });

        Session.set("ludo/hints", hints);
    },

    "mouseleave .piece": function (event, template) {
        clearGhostAndHints();
    }
});

Template.LudoControls.events({
    "click #roll-dice": function () {
        Meteor.call("ludo/rollDice", this.game._id);
    }
});
