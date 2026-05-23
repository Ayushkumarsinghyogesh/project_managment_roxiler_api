# 🗂️ Project Management API

A production-ready **Rails 7.1 API-only** application with JWT authentication, role-based access control (Pundit), pagination (Kaminari), N+1-free queries, filtering, and sorting.

---

## 🛠️ Tech Stack

| Concern | Solution | Gem |
|---------|----------|-----|
| Authentication | JWT tokens (24h expiry) | `jwt` + `bcrypt` |
| Authorization | Role-based policy objects | `pundit ~> 2.3` |
| Serialization | View-based blueprints | `blueprinter ~> 0.30` |
| Pagination | Page + per_page params | `kaminari ~> 1.2` |
| Database | SQLite3 (swap-ready for PG) | `sqlite3 ~> 1.4` |
| Server | Multi-threaded | `puma ~> 6.0` |

---

## ⚙️ Setup & Installation

**Prerequisites:** Ruby 3.2+, Bundler, SQLite3

```bash
# 1. Clone the repo
git clone https://github.com/your-username/project-management-api.git
cd project-management-api

# 2. Install gems
bundle install

# 3. Create DB, run migrations, seed sample data
rails db:create db:migrate db:seed

# 4. Start the server
rails server        # runs on http://localhost:3000
rails s -p 3009     # custom port
```

---

## 🌱 Seeded Credentials

The seed script creates **7 users**, **3 projects**, and **12 tasks** automatically.

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@example.com | password123 |
| Manager | bob@example.com | password123 |
| Manager | carol@example.com | password123 |
| Employee | employee1@example.com | password123 |
| Employee | employee2@example.com | password123 |
| Employee | employee3@example.com | password123 |
| Employee | employee4@example.com | password123 |

---

## 🔐 Authentication

Every request (except login and register) requires a **Bearer token** in the `Authorization` header.

### Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "message": "Logged in successfully.",
  "token": "eyJhbGci...",
  "user": { "id": 1, "name": "Alice Admin", "role": "admin" }
}
```

**Use the token in all subsequent requests:**
```http
Authorization: Bearer eyJhbGci...
```

---

## 🛡️ Authorization — Role Matrix

Powered by **Pundit** policy objects. Each role has a strict scope.

| Action | Admin | Manager | Employee |
|--------|-------|---------|----------|
| List projects | ✅ All | ✅ Own only | ✅ Has tasks |
| Create project | ✅ | ✅ | ❌ 403 |
| Update project | ✅ | ✅ Own only | ❌ 403 |
| Delete project | ✅ | ❌ 403 | ❌ 403 |
| List tasks | ✅ All | ✅ Own projects | ✅ Assigned only |
| Create task | ✅ | ✅ Own projects | ❌ 403 |
| Update task | ✅ | ✅ Own projects | ❌ 403 |
| Delete task | ✅ | ✅ Own projects | ❌ 403 |

---

## 📡 API Endpoints

### Auth

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/v1/auth/register` | No | Register new user |
| `POST` | `/api/v1/auth/login` | No | Login, get JWT token |
| `GET` | `/api/v1/auth/me` | Yes | Current user info |

### Projects

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/projects` | Yes | List projects (role-filtered, paginated) |
| `GET` | `/api/v1/projects/:id` | Yes | Single project with tasks + assignees |
| `POST` | `/api/v1/projects` | Yes | Create project (admin/manager) |
| `PATCH` | `/api/v1/projects/:id` | Yes | Update project |
| `DELETE` | `/api/v1/projects/:id` | Yes | Delete project (admin only) |

### Tasks

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/tasks` | Yes | List tasks (filtered, sorted, paginated) |
| `GET` | `/api/v1/tasks/:id` | Yes | Single task with project + assignee |
| `POST` | `/api/v1/tasks` | Yes | Create task (project manager only) |
| `PATCH` | `/api/v1/tasks/:id` | Yes | Update task |
| `DELETE` | `/api/v1/tasks/:id` | Yes | Delete task |

---

## 🔍 Filtering, Sorting & Pagination

Tasks support the following query parameters:

| Parameter | Type | Example | Description |
|-----------|------|---------|-------------|
| `status` | string | `pending` | Filter by task status |
| `assignee_id` | integer | `3` | Filter by assignee |
| `project_id` | integer | `1` | Filter by project |
| `sort_by` | string | `due_date` | Sort column (`status`, `priority`, `due_date`, `created_at`) |
| `sort_dir` | string | `desc` | Sort direction (`asc` / `desc`) |
| `page` | integer | `1` | Page number |
| `per_page` | integer | `10` | Records per page (max 100) |

**Example:**
```
GET /api/v1/tasks?status=pending&sort_by=priority&sort_dir=desc&page=1&per_page=5
Authorization: Bearer <token>
```

---

## 📋 Sample Requests

### Create a Task (Manager only)
```http
POST /api/v1/tasks
Authorization: Bearer <manager_token>
Content-Type: application/json

{
  "title": "Setup CI pipeline",
  "project_id": 1,
  "assignee_id": 4,
  "status": "pending",
  "priority": "high",
  "due_date": "2024-08-01"
}
```

**Response:**
```json
{
  "message": "Task created.",
  "task": {
    "id": 13,
    "title": "Setup CI pipeline",
    "status": "pending",
    "priority": "high",
    "due_date": "2024-08-01",
    "project": { "id": 1, "name": "E-Commerce Platform", "status": "active" },
    "assignee": { "id": 4, "name": "Employee 1", "email": "employee1@example.com" }
  }
}
```

### Duplicate Title → 422
```json
{ "errors": ["Title already exists in this project"] }
```

### Unauthorized Action → 403
```json
{ "error": "You are not authorized to perform this action." }
```

### No Token → 401
```json
{ "error": "Missing Authorization header." }
```

---

## ⚡ N+1 Query Prevention

All list endpoints use eager loading via the `with_full_details` scope.  
Fetching 100 projects with tasks and assignees fires **exactly 4 queries total**.

```ruby
# Project model
scope :with_full_details, -> {
  includes(:manager, tasks: :assignee)
}

# Result: 4 queries regardless of record count
# 1. SELECT projects
# 2. SELECT users WHERE id IN (manager_ids)
# 3. SELECT tasks WHERE project_id IN (...)
# 4. SELECT users WHERE id IN (assignee_ids)
```

---

## 🗃️ Project Structure

```
project_management_api/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb     # JWT auth + error handling
│   │   └── api/v1/
│   │       ├── auth_controller.rb        # register, login, me
│   │       ├── projects_controller.rb
│   │       └── tasks_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── project.rb                    # scopes, with_full_details
│   │   └── task.rb                       # filter + sort scopes
│   ├── policies/                         # Pundit RBAC
│   │   ├── application_policy.rb
│   │   ├── project_policy.rb
│   │   └── task_policy.rb
│   ├── serializers/                      # Blueprinter views
│   │   ├── user_blueprint.rb
│   │   ├── project_blueprint.rb
│   │   └── task_blueprint.rb
│   └── services/
│       └── jwt_service.rb                # encode / decode JWT
├── config/
│   ├── routes.rb
│   └── initializers/
│       ├── cors.rb
│       └── kaminari.rb
├── db/
│   ├── migrate/                          # 3 migrations
│   └── seeds.rb
└── README.md
```

---

## 📝 Assumptions

1. **Roles set at registration** — in production, only admins should assign manager/admin roles.
2. **Managers can only create tasks in their own projects** — enforced via Pundit `TaskPolicy`.
3. **Employees** can view task details and parent project info but cannot modify anything.
4. **Duplicate task titles** are blocked per project — enforced at model validation + DB unique index.
5. **JWT tokens expire in 24 hours** — configurable via `JwtService::EXPIRY`.
6. **SQLite3** used for development. Swap to PostgreSQL by updating `config/database.yml`.
7. **Shallow nested routes** available: `POST /api/v1/projects/:project_id/tasks` alongside flat routes.

---

## 🧪 Testing with Postman

A complete Postman collection (`project_management_api_postman.json`) is included with:

- ✅ Auto-saving tokens to environment variables on login
- ✅ Pre-written test scripts that verify status codes and response structure
- ✅ All CRUD operations for projects and tasks
- ✅ Authorization boundary tests (403, 401, 422)

**Import steps:**
1. Open Postman → **Import** → select `project_management_api_postman.json`
2. Create an environment with variable `base_url` = `http://localhost:3009`
3. Run **Login - Admin** first → token auto-saves
4. Run remaining requests in order

---

## 📄 License

MIT License — free to use and modify.
