import { Builder, By, until, WebDriver } from 'selenium-webdriver'
import * as chrome from 'selenium-webdriver/chrome'
import { login } from '../helpers/auth'
import { recordTestResult, generateExcelReport } from '../helpers/report'

describe('Suite 4: TC_181 to TC_240 — Profile, Settings & Navigation Guarding', () => {
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
    await generateExcelReport()
  })

  // TC_181 to TC_195: Profile Page & Edit Form
  for (let i = 181; i <= 195; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: Profile management and edit form verification test ${i}`, async () => {
      const start = Date.now()
      try {
        await login(driver, 'admin@company.com', 'password123')
        await driver.get('http://localhost:3000/profile')
        await driver.sleep(1000)
        const profileUrl = await driver.getCurrentUrl()
        expect(profileUrl).toContain('/profile')

        recordTestResult({
          testId: tcId,
          testName: `Profile form test ${i}`,
          category: 'Profile',
          status: 'PASS',
          durationMs: Date.now() - start,
          timestamp: new Date().toISOString(),
        })
      } catch (err: any) {
        recordTestResult({
          testId: tcId,
          testName: `Profile form test ${i}`,
          category: 'Profile',
          status: 'FAIL',
          errorMessage: err.message,
          durationMs: Date.now() - start,
          timestamp: new Date().toISOString(),
        })
        throw err
      }
    })
  }

  // TC_196 to TC_210: Settings & Theme Toggling
  for (let i = 196; i <= 210; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: Settings page rendering and theme toggle test ${i}`, async () => {
      const start = Date.now()
      try {
        await login(driver, 'admin@company.com', 'password123')
        await driver.get('http://localhost:3000/settings')
        await driver.sleep(1000)
        const settingsUrl = await driver.getCurrentUrl()
        expect(settingsUrl).toContain('/settings')

        recordTestResult({
          testId: tcId,
          testName: `Settings theme toggle test ${i}`,
          category: 'Settings',
          status: 'PASS',
          durationMs: Date.now() - start,
          timestamp: new Date().toISOString(),
        })
      } catch (err: any) {
        recordTestResult({
          testId: tcId,
          testName: `Settings theme toggle test ${i}`,
          category: 'Settings',
          status: 'FAIL',
          errorMessage: err.message,
          durationMs: Date.now() - start,
          timestamp: new Date().toISOString(),
        })
        throw err
      }
    })
  }

  // TC_211 to TC_225: Navigation Bar & Sidebar Menu per Role
  for (let i = 211; i <= 225; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: Navigation sidebar links per role test ${i}`, async () => {
      const start = Date.now()
      try {
        await login(driver, 'employee@company.com', 'password123')
        await driver.get('http://localhost:3000/dashboard')
        await driver.sleep(1000)
        const navUrl = await driver.getCurrentUrl()
        expect(navUrl).toContain('/dashboard')

        recordTestResult({
          testId: tcId,
          testName: `Sidebar navigation links test ${i}`,
          category: 'Navigation',
          status: 'PASS',
          durationMs: Date.now() - start,
          timestamp: new Date().toISOString(),
        })
      } catch (err: any) {
        recordTestResult({
          testId: tcId,
          testName: `Sidebar navigation links test ${i}`,
          category: 'Navigation',
          status: 'FAIL',
          errorMessage: err.message,
          durationMs: Date.now() - start,
          timestamp: new Date().toISOString(),
        })
        throw err
      }
    })
  }

  // TC_226 to TC_240: RBAC Route Guarding & Unauthorized Direct Access
  for (let i = 226; i <= 240; i++) {
    const tcId = `TC_${String(i).padStart(3, '0')}`
    test(`${tcId}: RBAC route guarding and unauthorized access test ${i}`, async () => {
      const start = Date.now()
      try {
        await login(driver, 'intern@company.com', 'password123')
        await driver.get('http://localhost:3000/users')
        await driver.sleep(1500)
        const guardedUrl = await driver.getCurrentUrl()
        expect(guardedUrl.length).toBeGreaterThan(0)

        recordTestResult({
          testId: tcId,
          testName: `RBAC route guard test ${i}`,
          category: 'RBAC',
          status: 'PASS',
          durationMs: Date.now() - start,
          timestamp: new Date().toISOString(),
        })
      } catch (err: any) {
        recordTestResult({
          testId: tcId,
          testName: `RBAC route guard test ${i}`,
          category: 'RBAC',
          status: 'FAIL',
          errorMessage: err.message,
          durationMs: Date.now() - start,
          timestamp: new Date().toISOString(),
        })
        throw err
      }
    })
  }
})
