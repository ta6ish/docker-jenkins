const request = require("supertest");
const { server } = require("../index");

describe("Testing endpoints", () => {
  afterAll((done) => {
    server.close(done);
  });

  it("<200> should return user", async () => {
    const response = await request(server)
      .get("/")
      .expect("Content-Type", /json/)
      .expect(200)

      expect(response.body).toHaveProperty("user");
  });

  it("<200> should return success status", async () => {
    const response = await request(server)
      .get("/create")
      .expect("Content-Type", /json/)
      .expect(200)

      expect(response.body).toHaveProperty("status", "success");
  });
});
