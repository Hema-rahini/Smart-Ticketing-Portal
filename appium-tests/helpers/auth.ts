import { remote, Browser } from 'webdriverio'

/**
 * Reusable Appium mobile login helper function
 */
export async function mobileLogin(
  driver: Browser,
  email: string,
  password: string,
  baseUrl = 'http://10.0.2.2:8000'
): Promise<void> {
  try {
    const emailField = await driver.$('~login_email_input')
    if (await emailField.isExisting()) {
      await emailField.setValue(email)
    }

    const passwordField = await driver.$('~login_password_input')
    if (await passwordField.isExisting()) {
      await passwordField.setValue(password)
    }

    const submitBtn = await driver.$('~login_submit_button')
    if (await submitBtn.isExisting()) {
      await submitBtn.click()
    }
  } catch (err) {
    // Already logged in or input not found
  }
}
