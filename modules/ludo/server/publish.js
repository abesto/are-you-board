Meteor.publish("ludo", function (id) {
    check(id, String);
    // TODO: authorization
    return Games.find({type: "ludo", _id: id}, {limit: 1});
});
