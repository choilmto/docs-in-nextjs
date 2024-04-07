import { test, expect } from '@playwright/test'

test('has title', async ({ page }) => {
  await page.goto('http://127.0.0.1:3000/')
  
  await expect(page).toHaveTitle(/Introduction/)

  await expect(page.locator('h1')).toContainText('Introduction')
});
