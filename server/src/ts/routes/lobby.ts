export function apply(app) {
    app.get("/", (req, res) => res.render("lobby"));
}
