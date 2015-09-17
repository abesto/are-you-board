import express = require("express");
const router = express.Router();

["login", "dev/board-test"].forEach((path) =>
    router.get("/" + path, (req, res) => res.render(path))
);

export = router
