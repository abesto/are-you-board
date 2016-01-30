function clearGhostAndHints() {
    Session.set("ludo/ghost", null);
    Session.set("ludo/hints", null);
}

Template.LudoField.events({
    "click .piece": function (event, template) {
        Meteor.call("ludo/move", template.parent(2).data.game._id, this.row, this.column);
        clearGhostAndHints();
    },

    "mouseenter .piece": function (event, template) {
        var game = template.parent(2).data.game;
        var nextPositions = Ludo.nextPositions(this.piece.side, this.piece.pos, game.dice);
        var last = nextPositions[nextPositions.length - 1];
        Session.set("ludo/ghost", {
            pos: last,
            side: this.piece.side
        });
        var hints = {};
        for (var i = 0; i < nextPositions.length; i++) {
            var pos = nextPositions[i];
            hints[pos.row + "," + pos.column] = i + 1;
        }
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
