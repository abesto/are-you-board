export function apply(app) {
    ["login", "dev/board-test"].forEach((path) =>
            app.get("/" + path, (req, res) => res.render(path))
    );
}
