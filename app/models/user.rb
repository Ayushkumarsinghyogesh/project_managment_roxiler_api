class User < ApplicationRecord
  has_secure_password

  ROLES = %w[admin manager employee].freeze

  has_many :managed_projects, class_name: "Project", foreign_key: :manager_id, dependent: :destroy
  has_many :assigned_tasks,   class_name: "Task",    foreign_key: :assignee_id, dependent: :nullify

  validates :name,  presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role,  inclusion: { in: ROLES }

  before_save { email.downcase! }

  def admin?    = role == "admin"
  def manager?  = role == "manager"
  def employee? = role == "employee"
end
