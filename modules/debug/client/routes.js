Router.route('/debug');
Router.route('/debug/1', {
    template: "LudoBoard",
    data: new LudoBoard()
});
