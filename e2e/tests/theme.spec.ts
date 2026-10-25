import { expect, test, type Page } from "@playwright/test";
import { gotoLive } from "./helpers";

const STORAGE_KEY = "phx:theme";

async function chooseTheme(page: Page, theme: string) {
  await page.locator("#theme-selector-toggle").click();
  await expect(page.locator("#theme-menu")).toBeVisible();
  await page.locator(`#theme-option-${theme}`).click();
}

const storedTheme = (page: Page) =>
  page.evaluate((key) => localStorage.getItem(key), STORAGE_KEY);

test.describe("theme selector", () => {
  test.use({ colorScheme: "dark" });

  test("follows the system colour scheme by default", async ({ page }) => {
    await gotoLive(page, "/");

    const html = page.locator("html");
    await expect(html).toHaveAttribute("data-theme", "dark");
    await expect(html).toHaveAttribute("data-theme-source", "system");
    await expect(page.locator("#theme-option-system")).toHaveAttribute("aria-checked", "true");
    expect(await storedTheme(page)).toBeNull();
  });

  test("persists the chosen theme in localStorage across reloads and pages", async ({ page }) => {
    await gotoLive(page, "/");

    await chooseTheme(page, "dracula");

    const html = page.locator("html");
    await expect(html).toHaveAttribute("data-theme", "dracula");
    await expect(html).toHaveAttribute("data-theme-source", "user");
    await expect(page.locator("#theme-option-dracula")).toHaveAttribute("aria-checked", "true");
    await expect(page.locator("#theme-option-system")).toHaveAttribute("aria-checked", "false");
    await expect(page.locator("#theme-selector-toggle [data-theme-label]")).toHaveText("Dracula");
    expect(await storedTheme(page)).toBe("dracula");

    await page.reload();
    await expect(html).toHaveAttribute("data-theme", "dracula");

    await gotoLive(page, "/projects/fpink");
    await expect(html).toHaveAttribute("data-theme", "dracula");
    await expect(page.locator("#theme-option-dracula")).toHaveAttribute("aria-checked", "true");
    await expect(page.locator("#theme-selector-toggle [data-theme-label]")).toHaveText("Dracula");

    await chooseTheme(page, "system");

    await expect(html).toHaveAttribute("data-theme", "dark");
    await expect(html).toHaveAttribute("data-theme-source", "system");
    expect(await storedTheme(page)).toBeNull();

    await page.reload();
    await expect(html).toHaveAttribute("data-theme", "dark");
  });

  test("applies every theme option", async ({ page }) => {
    await gotoLive(page, "/");
    const themes = await page
      .locator("#theme-menu [data-phx-theme]")
      .evaluateAll((els) =>
        els.map((el) => (el as HTMLElement).dataset.phxTheme!).filter((t) => t !== "system"),
      );
    expect(themes.length).toBeGreaterThan(1);

    for (const theme of themes) {
      await chooseTheme(page, theme);
      await expect(page.locator("html")).toHaveAttribute("data-theme", theme);
      expect(await storedTheme(page)).toBe(theme);
    }
  });

  test("ignores an unknown stored theme", async ({ page }) => {
    await page.addInitScript((key) => localStorage.setItem(key, "not-a-theme"), STORAGE_KEY);
    await gotoLive(page, "/");

    await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");
    await expect(page.locator("html")).toHaveAttribute("data-theme-source", "system");
  });

  test("syncs the theme to other open tabs", async ({ context }) => {
    const first = await context.newPage();
    const second = await context.newPage();
    await gotoLive(first, "/");
    await gotoLive(second, "/");

    await chooseTheme(first, "nord");

    await expect(second.locator("html")).toHaveAttribute("data-theme", "nord");
  });
});
