import { expect, test } from "@playwright/test";

test.describe("unknown routes", () => {
  test("an unknown project slug responds 404", async ({ page }) => {
    const response = await page.goto("/projects/does-not-exist");

    expect(response?.status()).toBe(404);
    await expect(page.locator("#project")).toHaveCount(0);
  });

  test("project slugs are case-sensitive", async ({ request }) => {
    const response = await request.get("/projects/FPINK");

    expect(response.status()).toBe(404);
  });

  test("an unknown path responds 404", async ({ request }) => {
    const response = await request.get("/projects/fpink/extra");

    expect(response.status()).toBe(404);
  });
});
