import { expect, test } from "@playwright/test";
import { PROJECT_SLUGS, gotoLive, waitForLiveView } from "./helpers";

test.describe("project navigation", () => {
  for (const slug of PROJECT_SLUGS) {
    test(`opens the ${slug} project page from the home page and back`, async ({ page }) => {
      await gotoLive(page, "/");
      const name = (await page.locator(`#project-${slug}-title-link`).innerText()).trim();

      await page.locator(`#project-${slug}-read-more`).click();

      await expect(page).toHaveURL(`/projects/${slug}`);
      await waitForLiveView(page);
      await expect(page.locator("#project-title")).toHaveText(name);
      await expect(page).toHaveTitle(`${name} · Massimiliano D'Acunzo`);
      await expect(page.locator("#project-links a").first()).toBeVisible();
      await expect(page.locator("#highlights-title")).toBeVisible();
      await expect(page.locator("#stack-title")).toBeVisible();

      const others = page.locator("#other-projects a");
      await expect(others).toHaveCount(PROJECT_SLUGS.length - 1);
      await expect(page.locator(`#other-project-${slug}`)).toHaveCount(0);

      await page.locator("#back-to-projects").click();

      await expect(page).toHaveURL(/\/#projects$/);
      await waitForLiveView(page);
      await expect(page.locator(`#project-${slug}`)).toBeVisible();
    });
  }

  test("title links, other-project links, the logo and browser history all navigate", async ({
    page,
  }) => {
    await gotoLive(page, "/");

    await page.locator("#project-fpink-title-link").click();
    await expect(page).toHaveURL("/projects/fpink");
    await waitForLiveView(page);

    await page.locator("#other-project-marknotes").click();
    await expect(page).toHaveURL("/projects/marknotes");
    await waitForLiveView(page);
    await expect(page.locator("#project-title")).toHaveText(/MarkNotes/i);

    await page.goBack();
    await expect(page).toHaveURL("/projects/fpink");
    await expect(page.locator("#project-title")).toHaveText(/FPInk/i);

    await page.goForward();
    await expect(page).toHaveURL("/projects/marknotes");
    await expect(page.locator("#project-title")).toHaveText(/MarkNotes/i);

    await page.locator("#home-link").click();
    await expect(page).toHaveURL("/");
    await waitForLiveView(page);
    await expect(page.locator("#hero h1")).toBeVisible();
  });

  test("opens a project page directly", async ({ page }) => {
    await gotoLive(page, "/projects/repentance");

    await expect(page.locator("#project")).toBeVisible();
    await expect(page.locator("#project-title")).toHaveText(/Repentance/i);
  });
});
