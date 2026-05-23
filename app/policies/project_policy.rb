class ProjectPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      case user.role
      when "admin"    then scope.all
      when "manager"  then scope.for_manager(user)
      when "employee" then scope.for_employee(user)
      else                 scope.none
      end
    end
  end

  # Admins and managers can see their own projects
  def show?
    admin? || manager_of_project? || employee_has_task?
  end

  def create?
    admin? || user.manager?
  end

  def update?
    admin? || manager_of_project?
  end

  def destroy?
    admin?
  end

  private

  def admin?
    user.admin?
  end

  def manager_of_project?
    user.manager? && record.manager_id == user.id
  end

  def employee_has_task?
    user.employee? && record.tasks.exists?(assignee_id: user.id)
  end
end
