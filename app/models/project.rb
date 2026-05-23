class Project < ApplicationRecord
  STATUSES = %w[active on_hold completed cancelled].freeze

  belongs_to :manager, class_name: "User"
  has_many   :tasks, dependent: :destroy

  validates :name,   presence: true, uniqueness: { case_sensitive: false }
  validates :status, inclusion: { in: STATUSES }

  scope :for_manager,  ->(user) { where(manager: user) }
  scope :for_employee, ->(user) {
    joins(:tasks).where(tasks: { assignee_id: user.id }).distinct
  }

  # Eager-load everything needed for the list endpoint in one query
  scope :with_full_details, -> {
    includes(
      :manager,
      tasks: :assignee
    )
  }
end
