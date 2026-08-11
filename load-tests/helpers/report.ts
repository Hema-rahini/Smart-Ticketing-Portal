import * as ExcelJS from 'exceljs'
import * as path from 'path'
import * as fs from 'fs'

export interface LoadTestResult {
  testId: string
  testName: string
  category: string
  targetConcurrency: number
  duration: string
  threshold: string
  measuredP95Ms: number
  measuredErrorRatePct: number
  status: 'PASS' | 'FAIL'
  fixApplied?: string
  timestamp: string
}

const testResults: LoadTestResult[] = []

export function recordLoadTestResult(result: LoadTestResult) {
  const existingIdx = testResults.findIndex(r => r.testId === result.testId)
  if (existingIdx >= 0) {
    testResults[existingIdx] = result
  } else {
    testResults.push(result)
  }
}

export async function generateLoadExcelReport(): Promise<string> {
  const workbook = new ExcelJS.Workbook()
  const worksheet = workbook.addWorksheet('Load Test Results')

  worksheet.columns = [
    { header: 'Test ID', key: 'testId', width: 12 },
    { header: 'Test Name', key: 'testName', width: 45 },
    { header: 'Category', key: 'category', width: 30 },
    { header: 'Target Concurrency (VUs)', key: 'targetConcurrency', width: 25 },
    { header: 'Duration', key: 'duration', width: 12 },
    { header: 'Threshold', key: 'threshold', width: 30 },
    { header: 'Measured p95 Latency (ms)', key: 'measuredP95Ms', width: 25 },
    { header: 'Measured Error Rate (%)', key: 'measuredErrorRatePct', width: 22 },
    { header: 'Status', key: 'status', width: 12 },
    { header: 'Fix Applied', key: 'fixApplied', width: 40 },
    { header: 'Timestamp', key: 'timestamp', width: 28 },
  ]

  // Header row formatting
  const headerRow = worksheet.getRow(1)
  headerRow.font = { bold: true, color: { argb: 'FFFFFF' } }
  headerRow.fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: '1E293B' }
  }

  // Sort by Test ID numerically
  testResults.sort((a, b) => {
    const numA = parseInt(a.testId.replace(/\D/g, ''), 10)
    const numB = parseInt(b.testId.replace(/\D/g, ''), 10)
    return numA - numB
  })

  for (const res of testResults) {
    const row = worksheet.addRow({
      testId: res.testId,
      testName: res.testName,
      category: res.category,
      targetConcurrency: res.targetConcurrency,
      duration: res.duration,
      threshold: res.threshold,
      measuredP95Ms: res.measuredP95Ms,
      measuredErrorRatePct: res.measuredErrorRatePct,
      status: res.status,
      fixApplied: res.fixApplied || 'N/A',
      timestamp: res.timestamp,
    })

    const statusCell = row.getCell('status')
    if (res.status === 'PASS') {
      statusCell.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'D1FAE5' }
      }
      statusCell.font = { color: { argb: '065F46' }, bold: true }
    } else {
      statusCell.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FEE2E2' }
      }
      statusCell.font = { color: { argb: '991B1B' }, bold: true }
    }
  }

  const reportsDir = path.resolve(__dirname, '../reports')
  if (!fs.existsSync(reportsDir)) {
    fs.mkdirSync(reportsDir, { recursive: true })
  }

  const reportPath = path.join(reportsDir, 'load-report.xlsx')
  await workbook.xlsx.writeFile(reportPath)
  return reportPath
}
