const request = require("supertest");
const app = require("./app");

test("GET /health returns ok", async () => {
  const res = await request(app).get("/health");
  expect(res.body.status).toBe("ok");
});

test("GET /hello/:name returns greeting", async () => {
  const res = await request(app).get("/hello/Irakli");
  expect(res.body.message).toBe("Hello, Irakli!");
});

test("POST /echo returns body", async () => {
  const res = await request(app).post("/echo").send({ x: 1 });
  expect(res.body.received.x).toBe(1);
});
