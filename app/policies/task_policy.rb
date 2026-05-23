class TaskPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      case user.role
      when "admin"    then scope.all
      when "manager"  then scope.joins(:project).where(projects: { manager_id: user.id })
      when "employee" then scope.where(assignee_id: user.id)
      else                 scope.none
      end
    end
  end

  def show?
    admin? || manager_of_project? || assignee?
  end

  # Only the project's manager can create tasks
  def create?
    return false unless record.project_id.present?

    project = record.project || Project.find_by(id: record.project_id)
    admin? || (user.manager? && project&.manager_id == user.id)
  end

  def update?
    admin? || manager_of_project?
  end

  def destroy?
    admin? || manager_of_project?
  end

  private

  def admin?
    user.admin?
  end

  def manager_of_project?
    user.manager? && record.project&.manager_id == user.id
  end

  def assignee?
    record.assignee_id == user.id
  end
end
