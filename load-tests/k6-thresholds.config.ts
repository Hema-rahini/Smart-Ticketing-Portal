export const K6_THRESHOLDS = {
  auth: {
    p95LatencyMs: 500,
    errorRatePct: 1.0,
  },
  tickets: {
    readP95Ms: 400,
    writeP95Ms: 800,
    errorRatePct: 1.0,
  },
  dashboard: {
    p95LatencyMs: 400,
    errorRatePct: 1.0,
  },
  messaging: {
    p95LatencyMs: 500,
    errorRatePct: 1.0,
  },
  provisioning: {
    p95LatencyMs: 800,
    errorRatePct: 1.0,
  },
  mobileUI: {
    maxLatencyMs: 1000,
    errorRatePct: 0.0,
  }
}
