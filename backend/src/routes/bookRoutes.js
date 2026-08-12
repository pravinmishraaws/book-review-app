const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");

module.exports = (sequelize) => {
  const bookController = require("../controllers/bookController")(sequelize);

  router.get("/", authMiddleware, bookController.getAllBooks);
  router.get("/:id", authMiddleware, bookController.getBookById); // Ensure this route exists
  router.post("/", bookController.addBook);

  return router;
};
