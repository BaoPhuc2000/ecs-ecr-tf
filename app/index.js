const express = require("express");
const app = express();
const PORT = process.env.PORT || 8080;

app.get("/", (req, res) => {
  res.json({
    message: "Xin chào từ ECS Fargate!",
    hostname: require("os").hostname(),
  });
});

app.get("/health", (req, res) => {
  res.status(200).send("OK");
});

app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
});
