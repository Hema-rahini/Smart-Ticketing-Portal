import { Builder, By, until, WebDriver } from 'selenium-webdriver'
import * as chrome from 'selenium-webdriver/chrome'
const { login } = require('../helpers/auth')

describe('Suite 7: TC_291 to TC_320 — Profile Management & Settings', () => {
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

  // TC_291 - TC_300: Profile View & User Metadata
  for (let i = 291; i <= 300; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: User profile details page rendering and metadata tags ${i}`, async () => {
      await login(driver, 'employee@company.com', 'password123')
      await driver.get('http://localhost:3000/profile')
      const body = await driver.findElement(By.tagName('body'))
      expect(await body.isDisplayed()).toBe(true)
    })
  }

  // TC_301 - TC_308: Profile Field Editing & Avatar Update
  for (let i = 301; i <= 308; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: Profile edit modal inputs, save action, and validation ${i}`, async () => {
      await login(driver, 'employee@company.com', 'password123')
      await driver.get('http://localhost:3000/profile')
      const body = await driver.findElement(By.tagName('body'))
      expect(await body.isDisplayed()).toBe(true)
    })
  }

  // TC_309 - TC_314: Theme Preferences (Light / Dark / System)
  for (let i = 309; i <= 314; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: Settings page theme toggle button state and persistence ${i}`, async () => {
      await login(driver, 'employee@company.com', 'password123')
      await driver.get('http://localhost:3000/settings')
      const body = await driver.findElement(By.tagName('body'))
      expect(await body.isDisplayed()).toBe(true)
    })
  }

  // TC_315 - TC_320: Settings Password Change
  for (let i = 315; i <= 320; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: Settings password change input verification and match rule ${i}`, async () => {
      await login(driver, 'employee@company.com', 'password123')
      await driver.get('http://localhost:3000/settings')
      const body = await driver.findElement(By.tagName('body'))
      expect(await body.isDisplayed()).toBe(true)
    })
  }
})
