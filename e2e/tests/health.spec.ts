import { expect, test } from "@playwright/test";

test("GET /health responds ok", async ({ request }) => {
  const response = await request.get("/health");

  expect(response.status()).toBe(200);
  expect((await response.text()).trim()).toBe("ok");
});
