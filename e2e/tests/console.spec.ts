import { expect, test } from "@playwright/test";
import { PROJECT_SLUGS, collectErrors, gotoLive } from "./helpers";

test.describe("browser console", () => {
  test("has no errors across pages and interactions", async ({ page }) => {
    const errors = collectErrors(page);

    await gotoLive(page, "/");
    await page.locator("#theme-selector-toggle").click();
    await page.locator("#theme-option-gruvbox").click();
    await page.locator("#hero-cta").click();

    for (const slug of PROJECT_SLUGS) {
      await gotoLive(page, `/projects/${slug}`);
    }

    await page.locator("#back-to-projects").click();
    await expect(page).toHaveURL(/\/#projects$/);
    await gotoLive(page, "/");

    expect(errors).toEqual([]);
  });
});
