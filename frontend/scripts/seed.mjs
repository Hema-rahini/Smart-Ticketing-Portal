import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("Supabase URL and Anon Key must be provided");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function seed() {
  console.log("Seeding sample data to Supabase...");

  // 1. Create a mock user to use their UUID
  console.log("Creating mock system user...");
  let systemUserId;
  const { data: existingSystem } = await supabase.from('users').select('id').eq('email', 'system@example.com').single();
  
  if (existingSystem) {
    systemUserId = existingSystem.id;
  } else {
    const { data: newUser, error: userError } = await supabase.from('users').insert({
      name: 'System Admin',
      email: 'system@example.com',
      role: 'admin'
    }).select('id').single();

    if (userError) {
      console.error("Error creating user:", userError.message);
      process.exit(1);
    }
    systemUserId = newUser.id;
  }

  // Seed Announcements
  const announcements = [
    {
      title: "Welcome to the new Smart Ticketing Portal!",
      content: "We're excited to launch our new support system. Please explore the dashboard and let us know if you find any issues.",
      author_id: systemUserId,
      is_pinned: true,
      target_roles: ["admin", "employee", "agent", "manager"]
    },
    {
      title: "Scheduled Maintenance this weekend",
      content: "The portal will be down for 2 hours on Sunday 2AM EST for database upgrades.",
      author_id: systemUserId,
      is_pinned: false,
      target_roles: ["admin", "employee", "agent", "manager"]
    }
  ];

  for (const ann of announcements) {
    const { error } = await supabase.from('announcements').insert(ann);
    if (error) console.error("Error inserting announcement:", error.message);
  }

  // Seed Tickets
  const tickets = [
    {
      title: "Cannot access email",
      description: "My outlook keeps crashing when I try to open my inbox.",
      status: "open",
      priority: "high",
      created_by: systemUserId,
      department: "IT",
      tags: ["email", "outlook"]
    },
    {
      title: "Request for new monitor",
      description: "I need a second monitor for my desk.",
      status: "in_progress",
      priority: "medium",
      created_by: systemUserId,
      assigned_to: [systemUserId],
      department: "Hardware",
      tags: ["hardware", "request"]
    },
    {
      title: "Office AC is too cold",
      description: "Can we adjust the temperature on the 3rd floor?",
      status: "resolved",
      priority: "low",
      created_by: systemUserId,
      department: "Facilities",
      tags: ["facilities"]
    }
  ];

  for (const ticket of tickets) {
    const { error } = await supabase.from('tickets').insert(ticket);
    if (error) console.error("Error inserting ticket:", error.message);
  }

  console.log("Seeding complete! Refresh your page to see the data.");
}

seed().catch(console.error);
