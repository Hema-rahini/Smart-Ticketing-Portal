export const TEST_USER_PATTERN = 'qa_tc_load_'

export interface SeededData {
  testUserIds: string[]
  createdTicketIds: string[]
}

export const globalSeededData: SeededData = {
  testUserIds: [],
  createdTicketIds: []
}

export function registerTestUser(userId: string) {
  if (!globalSeededData.testUserIds.includes(userId)) {
    globalSeededData.testUserIds.push(userId)
  }
}

export function registerTestTicket(ticketId: string) {
  if (!globalSeededData.createdTicketIds.includes(ticketId)) {
    globalSeededData.createdTicketIds.push(ticketId)
  }
}

export async function cleanupSeededData(): Promise<void> {
  // Teardown helper for qa_tc test users and created tickets
  globalSeededData.testUserIds = []
  globalSeededData.createdTicketIds = []
}
