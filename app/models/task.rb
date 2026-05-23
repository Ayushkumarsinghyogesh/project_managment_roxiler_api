class Task < ApplicationRecord
  STATUSES   = %w[pending in_progress review done].freeze
  PRIORITIES = %w[low medium high critical].freeze

  belongs_to :project
  belongs_to :assignee, class_name: "User"

  validates :title,    presence: true
  validates :status,   inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }, allow_nil: true
  validates :title,    uniqueness: {
    scope: :project_id,
    case_sensitive: false,
    message: "already exists in this project"
  }

  scope :by_status,   ->(s)    { where(status: s) if s.present? }
  scope :by_assignee, ->(id)   { where(assignee_id: id) if id.present? }
  scope :by_project,  ->(id)   { where(project_id: id) if id.present? }
  scope :sorted_by,   ->(col, dir) {
    allowed_columns = %w[status priority due_date created_at]
    col = allowed_columns.include?(col.to_s) ? col : "created_at"
    dir = %w[asc desc].include?(dir.to_s.downcase) ? dir : "asc"
    order("#{col} #{dir}")
  }
end
