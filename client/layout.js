Router.onBeforeAction(function () {
    if (Meteor.userId() === null && this.route && this.route.getName() !== 'login') {
        this.redirect('login');
    } else {
        this.next();
    }
});

Template.Layout.helpers({
    activeIfRouteIs: function(routeName) {
        var current = Router.current();
        if (current && routeName === current.route.getName()) {
            return 'active';
        } else {
            return '';
        }
    }
});
