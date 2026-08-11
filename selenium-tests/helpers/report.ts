import * as ExcelJS from 'exceljs'
import * as path from 'path'
import * as fs from 'fs'

export interface TestResultItem {
  testId: string
  testName: string
  category: string
  status: 'PASS' | 'FAIL'
  errorMessage?: string
  durationMs: number
  timestamp: string
  screenshotPath?: string
}

const resultsCollection: TestResultItem[] = []

export function recordTestResult(item: TestResultItem) {
  resultsCollection.push(item)
}

export function getRecordedResults(): TestResultItem[] {
  return resultsCollection
}

export async function generateExcelReport(results?: TestResultItem[], outputPath?: string): Promise<string> {
  const data = results && results.length > 0 ? results : resultsCollection
  
  const baseDir = process.cwd().endsWith('selenium-tests') ? process.cwd() : path.join(process.cwd(), 'selenium-tests')

  const targetPaths = [
    path.join(baseDir, 'reports', 'selenium-report.xlsx'),
    path.resolve(__dirname, '../reports/selenium-report.xlsx'),
  ]

  if (outputPath) {
    targetPaths.unshift(outputPath)
  }

  const existingMap = new Map<string, TestResultItem>()

  // Try to load existing entries from any existing report file
  for (const p of targetPaths) {
    if (fs.existsSync(p)) {
      try {
        const existingWorkbook = new ExcelJS.Workbook()
        await existingWorkbook.xlsx.readFile(p)
        const sheet = existingWorkbook.getWorksheet('Selenium Test Results')
        if (sheet) {
          sheet.eachRow((row, rowNumber) => {
            if (rowNumber > 1) {
              const testId = String(row.getCell(1).value || '')
              if (testId) {
                existingMap.set(testId, {
                  testId,
                  testName: String(row.getCell(2).value || ''),
                  category: String(row.getCell(3).value || ''),
                  status: String(row.getCell(4).value || '') === 'PASS' ? 'PASS' : 'FAIL',
                  errorMessage: String(row.getCell(5).value || ''),
                  durationMs: Number(row.getCell(6).value || 0),
                  timestamp: String(row.getCell(7).value || ''),
                  screenshotPath: String(row.getCell(8).value || ''),
                })
              }
            }
          })
        }
      } catch (e) {
        // Ignore read error
      }
    }
  }

  data.forEach(item => {
    existingMap.set(item.testId, item)
  })

  const newWorkbook = new ExcelJS.Workbook()
  const worksheet = newWorkbook.addWorksheet('Selenium Test Results')

  worksheet.columns = [
    { header: 'Test ID', key: 'testId', width: 12 },
    { header: 'Test Name', key: 'testName', width: 45 },
    { header: 'Category', key: 'category', width: 25 },
    { header: 'Status', key: 'status', width: 12 },
    { header: 'Error Message', key: 'errorMessage', width: 40 },
    { header: 'Duration (ms)', key: 'durationMs', width: 15 },
    { header: 'Timestamp', key: 'timestamp', width: 22 },
    { header: 'Screenshot Path', key: 'screenshotPath', width: 35 },
  ]

  // Style header
  worksheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFF' } }
  worksheet.getRow(1).fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: '1E293B' },
  }

  const sortedItems = Array.from(existingMap.values()).sort((a, b) => a.testId.localeCompare(b.testId))

  sortedItems.forEach((res) => {
    const row = worksheet.addRow({
      testId: res.testId,
      testName: res.testName,
      category: res.category,
      status: res.status,
      errorMessage: res.errorMessage || '',
      durationMs: res.durationMs,
      timestamp: res.timestamp,
      screenshotPath: res.screenshotPath || '',
    })

    const statusCell = row.getCell('status')
    if (res.status === 'PASS') {
      statusCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'DCFCE7' } }
      statusCell.font = { color: { argb: '166534' }, bold: true }
    } else {
      statusCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FEE2E2' } }
      statusCell.font = { color: { argb: '991B1B' }, bold: true }
    }
  })

  const writtenPaths = new Set<string>()
  for (const targetPath of targetPaths) {
    if (!writtenPaths.has(targetPath)) {
      writtenPaths.add(targetPath)
      const dir = path.dirname(targetPath)
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true })
      }
      await newWorkbook.xlsx.writeFile(targetPath)
    }
  }

  return targetPaths[0]
}
