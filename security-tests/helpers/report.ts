import * as ExcelJS from 'exceljs'
import * as path from 'path'
import * as fs from 'fs'

export interface SecurityTestResultItem {
  testId: string
  testName: string
  owaspCategory: string
  severity: 'Critical' | 'High' | 'Medium' | 'Low'
  status: 'PASS' | 'FAIL'
  findingDescription?: string
  fixApplied?: string
  durationMs: number
  timestamp: string
  screenshotPath?: string
}

const resultsCollection: SecurityTestResultItem[] = []

export function recordSecurityTestResult(item: SecurityTestResultItem) {
  resultsCollection.push(item)
}

export function getRecordedSecurityResults(): SecurityTestResultItem[] {
  return resultsCollection
}

export async function generateSecurityExcelReport(results?: SecurityTestResultItem[], outputPath?: string): Promise<string> {
  const data = results && results.length > 0 ? results : resultsCollection
  
  const baseDir = process.cwd().endsWith('security-tests') ? process.cwd() : path.join(process.cwd(), 'security-tests')

  const targetPaths = [
    path.join(baseDir, 'reports', 'security-report.xlsx'),
    path.resolve(process.cwd(), 'reports/security-report.xlsx'),
    path.resolve(__dirname, '../reports/security-report.xlsx'),
  ]

  if (outputPath) {
    targetPaths.unshift(outputPath)
  }

  const existingMap = new Map<string, SecurityTestResultItem>()

  for (const p of targetPaths) {
    if (fs.existsSync(p)) {
      try {
        const existingWorkbook = new ExcelJS.Workbook()
        await existingWorkbook.xlsx.readFile(p)
        const sheet = existingWorkbook.getWorksheet('Security Test Results')
        if (sheet) {
          sheet.eachRow((row, rowNumber) => {
            if (rowNumber > 1) {
              const testId = String(row.getCell(1).value || '')
              if (testId) {
                existingMap.set(testId, {
                  testId,
                  testName: String(row.getCell(2).value || ''),
                  owaspCategory: String(row.getCell(3).value || ''),
                  severity: (row.getCell(4).value as any) || 'Medium',
                  status: String(row.getCell(5).value || '') === 'PASS' ? 'PASS' : 'FAIL',
                  findingDescription: String(row.getCell(6).value || ''),
                  fixApplied: String(row.getCell(7).value || ''),
                  durationMs: Number(row.getCell(8).value || 0),
                  timestamp: String(row.getCell(9).value || ''),
                  screenshotPath: String(row.getCell(10).value || ''),
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
  const worksheet = newWorkbook.addWorksheet('Security Test Results')

  worksheet.columns = [
    { header: 'Test ID', key: 'testId', width: 12 },
    { header: 'Test Name', key: 'testName', width: 45 },
    { header: 'OWASP Category', key: 'owaspCategory', width: 25 },
    { header: 'Severity', key: 'severity', width: 12 },
    { header: 'Status', key: 'status', width: 12 },
    { header: 'Finding Description', key: 'findingDescription', width: 40 },
    { header: 'Fix Applied', key: 'fixApplied', width: 40 },
    { header: 'Duration (ms)', key: 'durationMs', width: 15 },
    { header: 'Timestamp', key: 'timestamp', width: 22 },
    { header: 'Screenshot/Log Path', key: 'screenshotPath', width: 35 },
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
      owaspCategory: res.owaspCategory,
      severity: res.severity,
      status: res.status,
      findingDescription: res.findingDescription || '',
      fixApplied: res.fixApplied || '',
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
