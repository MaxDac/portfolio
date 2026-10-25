import { defineConfig, devices } from "@playwright/test";

const port = Number(process.env.E2E_PORT || 4000);
// The dev endpoint binds to 127.0.0.1 only, so avoid "localhost" resolving to ::1.
const baseURL = `http://127.0.0.1:${port}`;

export default defineConfig({
  testDir: "./tests",
  timeout: 60_000,
  expect: { timeout: 10_000 },
  fullyParallel: false,
  workers: 1,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? [["github"], ["list"], ["html", { open: "never" }]] : "list",
  use: {
    baseURL,
    headless: true,
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
  },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
  webServer: {
    // Assets must be built beforehand (mix assets.build), watchers are disabled.
    command: "mix phx.server",
    cwd: "..",
    url: `${baseURL}/health`,
    reuseExistingServer: !process.env.CI,
    timeout: 180_000,
    env: { MIX_ENV: "dev", NO_WATCHERS: "1", PORT: String(port) },
  },
});
