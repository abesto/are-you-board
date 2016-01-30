Meteor.methods({
    "ludo/rollDice": function (gameId) {
        var dice = Math.floor(Math.random() * 6) + 1;
        return Games.update(
            {type: "ludo", _id: gameId},
            {$set: {dice: dice}}
        );
    }
});
