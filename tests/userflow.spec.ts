import { test, expect } from '@playwright/test'

test('should navigate to the about page', async ({ page }) => {
  await page.goto('http://127.0.0.1:3000/')

  await page.click('text=Another Page')

  await expect(page).toHaveURL('http://127.0.0.1:3000/another')
  
  await expect(page.locator('h1')).toContainText('Another Page')
})

test('should increment buttons', async ({ page }) => {
  await page.goto('http://127.0.0.1:3000/another')

  for (let i=0; i < 4; i++) {
    const compButton = page.getByRole('button').getByText(/Clicked/).first()
    await expect(compButton).toContainText(i.toString())
    await compButton.click()
    await expect(compButton).toContainText((i+1).toString())
    
    const extCompButton = page.getByRole('button').getByText(/Clicked/).nth(1)
    await expect (extCompButton).toContainText(i.toString())
    await extCompButton.click()
    await expect (extCompButton).toContainText((i+1).toString())
  }
})
