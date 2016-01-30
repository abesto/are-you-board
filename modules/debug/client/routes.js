Router.route('/debug');

Router.route('/debug/1', function() {
    var that = this;
    Meteor.call("ludo/create", function (err, id) {
        if (err) {
            throw err;
        }
        that.redirect("/debug/display/" + id);
    });
});

Router.route("/debug/display/:gameId", {
    template: "Ludo",
    waitOn: function () {
        return this.subscribe("ludo", this.params.gameId);
    },
    data: function () {
        return {
            game: Games.findOne({type: "ludo", _id: this.params.gameId})
        };
    }
});

Router.route('/debug/2', function () {
    var that = this;
    Meteor.call("ludo/create", function (err, id) {
        if (err) {
            throw err;
        }
        Meteor.call("ludo/addStartingPiecesForSide", id, Ludo.Sides.red);
        Meteor.call("ludo/addStartingPiecesForSide", id, Ludo.Sides.green);
        Meteor.call("ludo/addStartingPiecesForSide", id, Ludo.Sides.yellow);
        Meteor.call("ludo/addStartingPiecesForSide", id, Ludo.Sides.blue);
        that.redirect("/debug/display/" + id);
    });
});
