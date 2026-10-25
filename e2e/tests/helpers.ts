import { expect, type ConsoleMessage, type Page } from "@playwright/test";

export const PROJECT_SLUGS = [
  "fpink",
  "marknotes",
  "repentance",
  "privee",
  "tannhauser-gate",
] as const;

export const HOME_SECTIONS = ["hero", "about", "projects", "experience", "skills", "contact"] as const;

/** Waits until the LiveView on the page has joined over the websocket. */
export async function waitForLiveView(page: Page) {
  await expect(page.locator("[data-phx-main].phx-connected")).toBeVisible();
}

/** Opens a path and waits for the LiveView to be connected. */
export async function gotoLive(page: Page, path: string) {
  const response = await page.goto(path);
  expect(response?.status(), `GET ${path}`).toBe(200);
  await waitForLiveView(page);
  return response;
}

/** Collects console errors and uncaught page errors raised while the page is open. */
export function collectErrors(page: Page) {
  const errors: string[] = [];
  page.on("console", (msg: ConsoleMessage) => {
    if (msg.type() === "error") errors.push(`console: ${msg.text()}`);
  });
  page.on("pageerror", (err) => errors.push(`pageerror: ${err.message}`));
  return errors;
}
