const express = require("express");
require("dotenv").config();
const cors = require("cors");
const initializeDatabase = require("./config/db");

const app = express();
app.use(express.json());

// Read allowed origins from environment variables
const allowedOrigins = process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(",") : ["http://localhost:3000"];

app.use(cors({
  origin: function (origin, callback) {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true); // Allow requests from valid origins
    } else {
      callback(new Error("CORS policy: Not allowed by server"));
    }
  },
  credentials: true,
}));

// Debugging: Log incoming requests
app.use((req, res, next) => {
  console.log(`🛠 Incoming request from: ${req.headers.origin}`);
  next();
});

async function startServer() {
  try {
    // Initialize database
    const sequelize = await initializeDatabase();

    // Load models
    const User = require("./models/User")(sequelize);
    const Book = require("./models/Book")(sequelize);
    const Review = require("./models/Review")(sequelize);

    // Sync database in the correct order (Users -> Books -> Reviews)
    await User.sync({ alter: true });
    await Book.sync({ alter: true });
    await Review.sync({ alter: true });

    console.log("✅ Database schema updated successfully!");
    console.log("🛢️ Database connected successfully! Ready for queries.");

    // Insert sample users if table is empty
    const userCount = await User.count();
    if (userCount === 0) {
      await User.bulkCreate([
        { name: "John Doe", email: "john@example.com", password: "hashedpassword123" },
        { name: "Alice Smith", email: "alice@example.com", password: "hashedpassword456" }
      ]);
      console.log("👤 Sample users added!");
    }

    // Insert sample books if table is empty
    const bookCount = await Book.count();
    if (bookCount === 0) {
      await Book.bulkCreate([
        { title: "The Pragmatic Programmer", author: "Andrew Hunt", rating: 4.8 },
        { title: "Clean Code", author: "Robert C. Martin", rating: 4.7 },
        { title: "JavaScript: The Good Parts", author: "Douglas Crockford", rating: 4.5 },
      ]);
      console.log("📚 Sample books added!");
    }

    // Insert sample reviews if table is empty
    const reviewCount = await Review.count();
    if (reviewCount === 0) {
      await Review.bulkCreate([
        { userId: 1, bookId: 1, comment: "Fantastic book!", rating: 5, username: "John Doe" },
        { userId: 2, bookId: 2, comment: "Very insightful.", rating: 4, username: "Alice Smith" },
      ]);
      console.log("✍️ Sample reviews added!");
    }

    // Load routes
    const userRoutes = require("./routes/userRoutes")(sequelize);
    const bookRoutes = require("./routes/bookRoutes")(sequelize);
    const reviewRoutes = require("./routes/reviewRoutes")(sequelize);

    // Register API routes
    app.use("/api/users", userRoutes);
    app.use("/api/books", bookRoutes);
    app.use("/api/reviews", reviewRoutes);

    // Health check route
    app.get("/", (req, res) => {
      res.send("📚 Book Review API is running...");
    });

    // Start the server
    const PORT = process.env.PORT || 5000;
    app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
  } catch (error) {
    console.error("❌ Server startup failed:", error);
  }
}

// Start the server
startServer();
