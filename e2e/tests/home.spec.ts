import { expect, test } from "@playwright/test";
import { HOME_SECTIONS, PROJECT_SLUGS, gotoLive } from "./helpers";

test.describe("home page", () => {
  test("renders every section with a heading", async ({ page }) => {
    await gotoLive(page, "/");

    await expect(page).toHaveTitle(/Massimiliano D'Acunzo/);
    await expect(page.locator("#hero h1")).toBeVisible();

    for (const id of HOME_SECTIONS) {
      await expect(page.locator(`#${id}`), `section #${id}`).toBeAttached();
    }

    for (const id of HOME_SECTIONS.filter((id) => id !== "hero")) {
      await page.locator(`#${id}`).scrollIntoViewIfNeeded();
      await expect(page.locator(`#${id}-title`), `heading of #${id}`).toBeVisible();
    }
  });

  test("lists a card for every project", async ({ page }) => {
    await gotoLive(page, "/");

    await expect(page.locator("#projects article.card")).toHaveCount(PROJECT_SLUGS.length);
    for (const slug of PROJECT_SLUGS) {
      await expect(page.locator(`#project-${slug}-title-link`)).toHaveAttribute(
        "href",
        `/projects/${slug}`,
      );
      await expect(page.locator(`#project-${slug}-read-more`)).toBeVisible();
    }
  });

  test("renders the header, desktop section nav and footer", async ({ page }) => {
    await gotoLive(page, "/");

    await expect(page.locator("#site-header")).toBeVisible();
    await expect(page.locator("#section-nav")).toBeVisible();
    await expect(page.locator("#mobile-menu-toggle")).toBeHidden();
    await expect(page.locator("#theme-selector-toggle")).toBeVisible();
    await expect(page.locator("#site-footer")).toContainText(String(new Date().getUTCFullYear()));
  });

  test("hero call to action jumps to the projects section", async ({ page }) => {
    await gotoLive(page, "/");

    await page.locator("#hero-cta").click();

    await expect(page).toHaveURL(/#projects$/);
    await expect(page.locator("#projects-title")).toBeInViewport();
  });

  test("section nav links scroll to their section", async ({ page }) => {
    await gotoLive(page, "/");

    for (const id of ["about", "projects", "experience", "skills"]) {
      await page.locator(`#section-nav a[href="/#${id}"]`).click();
      await expect(page).toHaveURL(new RegExp(`#${id}$`));
      await expect(page.locator(`#${id}-title`)).toBeInViewport();
    }
  });
});
