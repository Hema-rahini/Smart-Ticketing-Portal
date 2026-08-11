import { By, until, WebDriver } from 'selenium-webdriver'

/**
 * Reusable Selenium login helper function
 */
export async function login(driver: WebDriver, email: string, password: string, baseUrl = 'http://localhost:3000'): Promise<void> {
  await driver.get(baseUrl)
  await driver.sleep(500)

  try {
    const emailInput = await driver.wait(
      until.elementLocated(By.css('[data-testid="login-email-input"], input[type="email"]')),
      3000
    )
    await emailInput.clear()
    await emailInput.sendKeys(email)

    const passwordInput = await driver.wait(
      until.elementLocated(By.css('[data-testid="login-password-input"], input[type="password"]')),
      3000
    )
    await passwordInput.clear()
    await passwordInput.sendKeys(password)

    const submitButton = await driver.wait(
      until.elementLocated(By.css('[data-testid="login-submit-button"], button[type="submit"]')),
      3000
    )
    await submitButton.click()
  } catch (err) {
    // Already logged in or input not found
  }

  await driver.sleep(1500)
}
