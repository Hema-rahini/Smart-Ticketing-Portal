import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = 'https://cppqgkzogzxywwabtmnz.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwcHFna3pvZ3p4eXd3YWJ0bW56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMjE1MjEsImV4cCI6MjA5NjY5NzUyMX0.ac00bdM_oFw2M8BSuiN7rV0sAZOa0Cz9GDgV6nbxrns'

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

async function seed() {
  console.log('Starting comprehensive seed...')
  
  const dummyUsers = [
    { email: 'manager.dummy@example.com', password: 'password123', name: 'Bob Manager', role: 'manager', department: 'Engineering' },
    { email: 'employee.dummy@example.com', password: 'password123', name: 'Charlie Employee', role: 'employee', department: 'Engineering' },
    { email: 'intern.dummy@example.com', password: 'password123', name: 'Diana Intern', role: 'intern', department: 'Support' },
    { email: 'support.lead@example.com', password: 'password123', name: 'Edward Support', role: 'manager', department: 'Support' },
    { email: 'qa.analyst@example.com', password: 'password123', name: 'Fiona QA', role: 'employee', department: 'Quality Assurance' },
  ]

  const userIds = {}

  for (const u of dummyUsers) {
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: u.email,
      password: u.password
    })
    
    if (authError) {
      const { data: existingUser } = await supabase.from('users').select('id').eq('email', u.email).single()
      if (existingUser) {
        userIds[u.role] = existingUser.id
      }
      continue
    }

    if (authData.user) {
      const { data: newUser, error: insertError } = await supabase.from('users').insert({
        id: authData.user.id,
        name: u.name,
        email: u.email,
        role: u.role,
        department: u.department
      }).select().single()

      if (!insertError && newUser) {
        userIds[u.role] = newUser.id
      }
    }
  }

  // Retrieve all users from database so we can assign specific tickets and messages to every user
  const { data: dbUsersList } = await supabase.from('users').select('id, email, name, role')
  const usersByRole = {
    admin: [],
    manager: [],
    employee: [],
    intern: []
  }

  const userMapByEmail = {}

  if (dbUsersList) {
    for (const u of dbUsersList) {
      if (usersByRole[u.role]) {
        usersByRole[u.role].push(u)
      }
      userMapByEmail[u.email] = u
    }
  }

  // Get sample users for relationships
  const mgr1 = userMapByEmail['manager.dummy@example.com'] || dbUsersList[0]
  const mgr2 = userMapByEmail['support.lead@example.com'] || dbUsersList[1]
  const emp1 = userMapByEmail['employee.dummy@example.com'] || dbUsersList[2]
  const emp2 = userMapByEmail['qa.analyst@example.com'] || dbUsersList[3]
  const intern1 = userMapByEmail['intern.dummy@example.com'] || dbUsersList[4]
  const adminUser = usersByRole['admin'][0] || mgr1

  console.log('Seeding comprehensive tickets for every user...')
  const tickets = [
    // Manager 1 tickets
    { title: 'Approve Q3 Engineering Budget', description: 'Review software subscriptions and server scaling budget allocation for Q3.', status: 'in-progress', priority: 'high', created_by: mgr1.id, assigned_to: [mgr1.id], department: 'Engineering', tags: ['budget', 'planning'] },
    { title: 'Refactor Authentication Middleware', description: 'Ensure JWT tokens are validated with tight expiration limits across APIs.', status: 'open', priority: 'high', created_by: mgr1.id, assigned_to: [emp1.id], department: 'Engineering', tags: ['auth', 'security'] },
    
    // Support Lead (Manager 2) tickets
    { title: 'Resolve High Priority Support Escalation', description: 'Tier 3 enterprise client requested immediate patch for webhook callback failures.', status: 'in-progress', priority: 'urgent', created_by: mgr2.id, assigned_to: [emp2.id], department: 'Support', tags: ['support', 'urgent'] },
    { title: 'Customer Feedback Report Q2', description: 'Synthesize support ticket resolution metrics and present to executive management.', status: 'completed', priority: 'medium', created_by: mgr2.id, assigned_to: [intern1.id], department: 'Support', tags: ['report', 'analytics'] },

    // Employee 1 tickets
    { title: 'Fix login page layout overflow', description: 'The role selection grid overflows on mobile screens under tight pixel boundaries.', status: 'completed', priority: 'high', created_by: emp1.id, assigned_to: [emp1.id], department: 'Engineering', tags: ['bug', 'ui', 'mobile'] },
    { title: 'Add Push Notification Service', description: 'Integrate notification triggers for ticket status changes and announcements.', status: 'in-progress', priority: 'medium', created_by: emp1.id, assigned_to: [emp1.id, intern1.id], department: 'Engineering', tags: ['notifications'] },

    // Employee 2 (QA Analyst) tickets
    { title: 'Automate End-to-End Cypress Tests', description: 'Write automated E2E tests for ticket creation, status updates, and user login flow.', status: 'in-progress', priority: 'high', created_by: emp2.id, assigned_to: [emp2.id], department: 'Quality Assurance', tags: ['testing', 'e2e'] },
    { title: 'Cross-browser Compatibility Audit', description: 'Test portal features on Safari, Firefox, Chrome, and Edge browsers.', status: 'completed', priority: 'low', created_by: emp2.id, assigned_to: [emp2.id], department: 'Quality Assurance', tags: ['qa', 'browser'] },

    // Intern tickets
    { title: 'Update API documentation for v2', description: 'Need to update the FastAPI OpenAPI documentation for ticket and user schemas.', status: 'in-progress', priority: 'medium', created_by: intern1.id, assigned_to: [intern1.id], department: 'Engineering', tags: ['docs', 'backend'] },
    { title: 'Build FAQ Page for Support Portal', description: 'Design and implement a responsive FAQ accordion component for new users.', status: 'open', priority: 'low', created_by: intern1.id, assigned_to: [intern1.id], department: 'Support', tags: ['frontend', 'faq'] },

    // Admin tickets
    { title: 'System Security Audit & RLS Policies', description: 'Perform full security audit across Supabase RLS policies and admin permissions.', status: 'in-progress', priority: 'high', created_by: adminUser.id, assigned_to: [adminUser.id, mgr1.id], department: 'Management', tags: ['security', 'admin'] }
  ]

  for (const t of tickets) {
    await supabase.from('tickets').insert(t)
  }

  console.log('Seeding rich dummy announcements...')
  const announcements = [
    { title: 'Welcome to Smart Ticketing Portal 2.0!', content: 'We have launched our upgraded collaborative ticket and task management platform across web and mobile!', author_id: adminUser.id, is_pinned: true, target_roles: ['admin', 'manager', 'employee', 'intern'] },
    { title: 'Q3 All Hands & Product Roadmap Meeting', content: 'Join us tomorrow at 10:00 AM UTC for the quarterly vision alignment and engineering update.', author_id: mgr1.id, is_pinned: true, target_roles: ['admin', 'manager', 'employee', 'intern'] },
    { title: 'Scheduled Server Maintenance Window', content: 'Database cluster maintenance will occur this Saturday between 00:00 AM and 02:00 AM UTC.', author_id: adminUser.id, is_pinned: false, target_roles: ['admin', 'manager', 'employee', 'intern'] },
    { title: 'New Intern Orientation Guide', content: 'Please review the updated onboarding guidelines and submit your completed tasks in the portal.', author_id: mgr2.id, is_pinned: false, target_roles: ['intern', 'employee'] },
  ]

  for (const a of announcements) {
    await supabase.from('announcements').insert(a)
  }

  console.log('Seeding rich 2-way conversations between all users...')
  const messages = [
    // Manager 1 <-> Employee 1
    { content: 'Hey Charlie, how is the push notification integration coming along?', sender_id: mgr1.id, receiver_id: emp1.id },
    { content: 'Hi Bob! Backend endpoints are ready. Just working on the trigger hooks now.', sender_id: emp1.id, receiver_id: mgr1.id },
    { content: 'Awesome! Let me know if you need help testing the Supabase real-time updates.', sender_id: mgr1.id, receiver_id: emp1.id },

    // Manager 2 <-> Intern 1
    { content: 'Hi Diana, could you share the initial draft of the FAQ component?', sender_id: mgr2.id, receiver_id: intern1.id },
    { content: 'Hi Edward! Yes, I just pushed the code. The accordion layout is live.', sender_id: intern1.id, receiver_id: mgr2.id },
    { content: 'Looks great! I will review it right after the support sync.', sender_id: mgr2.id, receiver_id: intern1.id },

    // Employee 1 <-> Employee 2 (QA)
    { content: 'Hey Fiona, the mobile UI overflow bug is fixed and ready for QA testing.', sender_id: emp1.id, receiver_id: emp2.id },
    { content: 'Thanks Charlie! Adding it to my test execution suite now.', sender_id: emp2.id, receiver_id: emp1.id },

    // Admin <-> Manager 1
    { content: 'Bob, please review the Q3 security audit report when you get a chance.', sender_id: adminUser.id, receiver_id: mgr1.id },
    { content: 'On it! I will go through the RLS policies and send my feedback today.', sender_id: mgr1.id, receiver_id: adminUser.id }
  ]

  for (const m of messages) {
    await supabase.from('messages').insert(m)
  }

  console.log('Comprehensive seed completed successfully!')
}

seed().catch(console.error)
