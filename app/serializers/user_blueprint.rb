class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :email, :role, :created_at

  view :with_stats do
    association :managed_projects, blueprint: ProjectBlueprint, view: :minimal
    association :assigned_tasks,   blueprint: TaskBlueprint,   view: :minimal
  end
end
