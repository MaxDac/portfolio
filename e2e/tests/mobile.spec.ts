import { devices, expect, test } from "@playwright/test";
import { gotoLive, waitForLiveView } from "./helpers";

// Pixel 7 runs on Chromium, unlike the iPhone presets which need WebKit.
const { defaultBrowserType: _browser, ...pixel7 } = devices["Pixel 7"];

test.describe("mobile layout", () => {
  test.use(pixel7);

  test("swaps the section nav for the mobile menu", async ({ page }) => {
    await gotoLive(page, "/");

    await expect(page.locator("#section-nav")).toBeHidden();
    await expect(page.locator("#mobile-menu-toggle")).toBeVisible();
    await expect(page.locator("#theme-selector-toggle")).toBeVisible();
    await expect(page.locator("#mobile-menu")).toBeHidden();

    await page.locator("#mobile-menu-toggle").click();
    await expect(page.locator("#mobile-menu")).toBeVisible();

    await page.locator('#mobile-menu a[href="/#experience"]').click();
    await expect(page).toHaveURL(/#experience$/);
    await expect(page.locator("#experience-title")).toBeInViewport();
  });

  for (const path of ["/", "/projects/fpink"]) {
    test(`does not overflow horizontally on ${path}`, async ({ page }) => {
      await gotoLive(page, path);

      const { scrollWidth, innerWidth } = await page.evaluate(() => ({
        scrollWidth: document.documentElement.scrollWidth,
        innerWidth: window.innerWidth,
      }));
      expect(scrollWidth).toBeLessThanOrEqual(innerWidth);
    });
  }

  test("stacks project cards in a single column", async ({ page }) => {
    await gotoLive(page, "/");

    const boxes = await page
      .locator("#projects article.card")
      .evaluateAll((cards) => cards.map((c) => c.getBoundingClientRect().left));
    expect(new Set(boxes.map(Math.round)).size).toBe(1);
  });

  test("opens a project from the home page", async ({ page }) => {
    await gotoLive(page, "/");

    await page.locator("#project-privee-read-more").click();

    await expect(page).toHaveURL("/projects/privee");
    await waitForLiveView(page);
    await expect(page.locator("#project-title")).toBeVisible();
  });
});
