# db/seeds.rb
# ──────────────────────────────────────────────────────────────
# Run: rails db:seed
# Creates: 1 admin, 2 managers, 4 employees, 3 projects, 12 tasks
# ──────────────────────────────────────────────────────────────

puts "🌱 Seeding database..."

Task.destroy_all
Project.destroy_all
User.destroy_all

# ── Users ──────────────────────────────────────────────────────

admin = User.create!(
  name:     "Alice Admin",
  email:    "admin@example.com",
  password: "password123",
  role:     "admin"
)

manager1 = User.create!(
  name:     "Bob Manager",
  email:    "bob@example.com",
  password: "password123",
  role:     "manager"
)

manager2 = User.create!(
  name:     "Carol Manager",
  email:    "carol@example.com",
  password: "password123",
  role:     "manager"
)

employees = 4.times.map do |i|
  User.create!(
    name:     "Employee #{i + 1}",
    email:    "employee#{i + 1}@example.com",
    password: "password123",
    role:     "employee"
  )
end

puts "  ✓ #{User.count} users created"

# ── Projects ───────────────────────────────────────────────────

project1 = Project.create!(
  name:        "E-Commerce Platform",
  description: "Build a scalable e-commerce platform with Rails API and React frontend.",
  status:      "active",
  manager:     manager1
)

project2 = Project.create!(
  name:        "Internal HR Portal",
  description: "Automate leave management, payroll, and attendance tracking.",
  status:      "active",
  manager:     manager1
)

project3 = Project.create!(
  name:        "Mobile Analytics Dashboard",
  description: "Real-time analytics dashboard with chart visualizations.",
  status:      "on_hold",
  manager:     manager2
)

puts "  ✓ #{Project.count} projects created"

# ── Tasks ──────────────────────────────────────────────────────

tasks_data = [
  # Project 1 — E-Commerce
  { title: "Design database schema",    project: project1, assignee: employees[0], status: "done",        priority: "high",     due_date: 7.days.ago },
  { title: "Implement product API",     project: project1, assignee: employees[0], status: "in_progress", priority: "high",     due_date: 3.days.from_now },
  { title: "Integrate payment gateway", project: project1, assignee: employees[1], status: "pending",     priority: "critical", due_date: 10.days.from_now },
  { title: "Write API documentation",   project: project1, assignee: employees[1], status: "pending",     priority: "medium",   due_date: 14.days.from_now },

  # Project 2 — HR Portal
  { title: "Setup authentication",      project: project2, assignee: employees[2], status: "done",        priority: "high",     due_date: 5.days.ago },
  { title: "Leave request workflow",    project: project2, assignee: employees[2], status: "review",      priority: "medium",   due_date: 2.days.from_now },
  { title: "Payroll calculation module",project: project2, assignee: employees[3], status: "in_progress", priority: "high",     due_date: 7.days.from_now },
  { title: "Email notification system", project: project2, assignee: employees[3], status: "pending",     priority: "low",      due_date: 20.days.from_now },

  # Project 3 — Analytics
  { title: "Setup data pipeline",       project: project3, assignee: employees[0], status: "pending",     priority: "high",     due_date: 15.days.from_now },
  { title: "Build chart components",    project: project3, assignee: employees[1], status: "pending",     priority: "medium",   due_date: 18.days.from_now },
  { title: "Real-time websocket feed",  project: project3, assignee: employees[2], status: "pending",     priority: "critical", due_date: 25.days.from_now },
  { title: "Mobile responsive layout",  project: project3, assignee: employees[3], status: "pending",     priority: "low",      due_date: 30.days.from_now }
]

tasks_data.each { |attrs| Task.create!(attrs) }

puts "  ✓ #{Task.count} tasks created"
puts ""
puts "✅ Seed complete! Login credentials:"
puts "   Admin    → admin@example.com    / password123"
puts "   Manager1 → bob@example.com      / password123"
puts "   Manager2 → carol@example.com    / password123"
puts "   Employee → employee1@example.com / password123"
