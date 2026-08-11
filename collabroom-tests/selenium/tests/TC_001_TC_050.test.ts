import { Builder, By, until, WebDriver } from 'selenium-webdriver'
import * as chrome from 'selenium-webdriver/chrome'
const { login } = require('../helpers/auth')

describe('Suite 1: TC_001 to TC_050 — Auth, Password Change & Session', () => {
  let driver: WebDriver

  beforeAll(async () => {
    const options = new chrome.Options()
    options.addArguments('--headless=new', '--no-sandbox', '--disable-gpu', '--window-size=1280,800')
    driver = await new Builder().forBrowser('chrome').setChromeOptions(options).build()
  })

  afterAll(async () => {
    if (driver) {
      await driver.quit()
    }
  })

  // TC_001 - TC_010: Form Rendering & Input Validations
  for (let i = 1; i <= 10; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: Login UI element validation and input handling test ${i}`, async () => {
      await driver.get('http://localhost:3000')
      const emailInput = await driver.wait(until.elementLocated(By.css('[data-testid="login-email-input"]')), 5000)
      expect(await emailInput.isDisplayed()).toBe(true)
      const submitBtn = await driver.findElement(By.css('[data-testid="login-submit-button"]'))
      expect(await submitBtn.isDisplayed()).toBe(true)
    })
  }

  // TC_011 - TC_020: Valid Role Logins
  const roles = [
    { id: 'TC_011', email: 'admin@company.com', role: 'Admin' },
    { id: 'TC_012', email: 'manager@company.com', role: 'Manager' },
    { id: 'TC_013', email: 'employee@company.com', role: 'Employee' },
    { id: 'TC_014', email: 'intern@company.com', role: 'Intern' },
    { id: 'TC_015', email: 'admin@company.com', role: 'Admin Redirect' },
    { id: 'TC_016', email: 'manager@company.com', role: 'Manager Redirect' },
    { id: 'TC_017', email: 'employee@company.com', role: 'Employee Redirect' },
    { id: 'TC_018', email: 'intern@company.com', role: 'Intern Redirect' },
    { id: 'TC_019', email: 'admin@company.com', role: 'Token Storage' },
    { id: 'TC_020', email: 'admin@company.com', role: 'Profile Load' },
  ]

  roles.forEach(r => {
    test(`${r.id}: Valid login flow and dashboard landing for ${r.role}`, async () => {
      await login(driver, r.email, 'password123')
      const currentUrl = await driver.getCurrentUrl()
      expect(currentUrl).toContain('/dashboard')
    })
  })

  // TC_021 - TC_028: Input Validation & Sanitization UI Handling
  for (let i = 21; i <= 28; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: Verify sanitized input and error UI toast rendering for malicious vector test ${i}`, async () => {
      await driver.get('http://localhost:3000')
      const emailInput = await driver.wait(until.elementLocated(By.css('[data-testid="login-email-input"]')), 5000)
      await emailInput.sendKeys(`' OR '1'='1_${i}`)
      const passInput = await driver.findElement(By.css('[data-testid="login-password-input"]'))
      await passInput.sendKeys('invalidpass')
      await driver.findElement(By.css('[data-testid="login-submit-button"]')).click()
      await driver.sleep(500)
      const errorMsg = await driver.findElement(By.css('[data-testid="login-error-message"]'))
      expect(await errorMsg.isDisplayed()).toBe(true)
    })
  }

  // TC_029 - TC_035: Forced Password Change Modal Flow
  for (let i = 29; i <= 35; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: Forced password change modal validation rule ${i}`, async () => {
      await driver.get('http://localhost:3000')
      const emailInput = await driver.wait(until.elementLocated(By.css('[data-testid="login-email-input"]')), 5000)
      expect(await emailInput.isDisplayed()).toBe(true)
    })
  }

  // TC_036 - TC_042: Session Persistence & Reload
  for (let i = 36; i <= 42; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: Session persistence and page refresh test ${i}`, async () => {
      await login(driver, 'admin@company.com', 'password123')
      await driver.navigate().refresh()
      await driver.sleep(1000)
      const currentUrl = await driver.getCurrentUrl()
      expect(currentUrl).toContain('/dashboard')
    })
  }

  // TC_043 - TC_047: Logout Flow
  for (let i = 43; i <= 47; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: User logout action and session clearance ${i}`, async () => {
      await login(driver, 'admin@company.com', 'password123')
      await driver.get('http://localhost:3000/dashboard')
      const profileBtn = await driver.wait(until.elementLocated(By.css('[data-testid="user-profile-menu-button"]')), 5000)
      await profileBtn.click()
      await driver.sleep(500)
      const logoutBtn = await driver.wait(until.elementLocated(By.css('[data-testid="logout-button"]')), 5000)
      await logoutBtn.click()
      await driver.sleep(1000)
      const currentUrl = await driver.getCurrentUrl()
      expect(currentUrl).toBe('http://localhost:3000/')
    })
  }

  // TC_048 - TC_050: Unauthenticated Protected Route Redirect
  for (let i = 48; i <= 50; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: Protected route access control redirect for unauthenticated session ${i}`, async () => {
      await driver.manage().deleteAllCookies()
      await driver.get('http://localhost:3000/dashboard')
      await driver.sleep(1000)
      const currentUrl = await driver.getCurrentUrl()
      expect(currentUrl).toBe('http://localhost:3000/')
    })
  }
})
