Router.configure({
    layoutTemplate: 'Layout'
});

Router.route('/', function () { this.redirect("lobby"); });
Router.route('/logout', function () {
    Meteor.logout();
    this.redirect("/");
});
