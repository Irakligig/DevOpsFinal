const express = require("express");
const app = express();
app.use(express.json());

app.get("/health", (req, res) => res.json({ status: "ok", service: "express-api" }));
app.get("/hello/:name", (req, res) =>
  res.json({ message: `Hello, ${req.params.name}!` }),
);
app.post("/echo", (req, res) => res.json({ received: req.body }));

const PORT = process.env.PORT || 3000;
if (require.main === module) app.listen(PORT, () => console.log(`API listening on ${PORT}`));
module.exports = app;
