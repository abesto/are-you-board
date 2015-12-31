Router.route('/login', function () {
    this.layout(null);
    if (Meteor.userId() !== null) {
        Router.go("/");
    } else {
        this.render("Login");
    }
});
