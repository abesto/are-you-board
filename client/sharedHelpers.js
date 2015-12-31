Template.registerHelper('displayName', function (user) {
    var i;
    for (i = 0; i < userDisplayNameFields.length; i++) {
        try {
            return eval('user.' + userDisplayNameFields[i]);
        } catch(e) {}
    }
    return '';
});

Template.registerHelper('userLink', function (user) {
    if (!user) {
        return '#';
    }
    if (user.services.facebook) {
        return user.services.facebook.link;
    }
    return "#";
});
