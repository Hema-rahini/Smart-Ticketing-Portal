export const config = {
  runner: 'local',
  port: 4723,
  specs: ['./tests/**/*.test.ts'],
  maxInstances: 1,
  capabilities: [{
    platformName: 'Android',
    'appium:deviceName': 'Android Emulator',
    'appium:platformVersion': '13.0',
    'appium:automationName': 'UiAutomator2',
    'appium:app': '../flutter_app/build/app/outputs/flutter-apk/app-debug.apk',
    'appium:autoGrantPermissions': true,
  }],
  logLevel: 'info',
  framework: 'mocha',
  reporters: ['spec'],
  mochaOpts: {
    ui: 'bdd',
    timeout: 60000
  }
}
