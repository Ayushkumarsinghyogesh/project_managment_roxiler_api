class TaskBlueprint < Blueprinter::Base
  identifier :id

  # minimal view — used inside project listings
  view :minimal do
    fields :title, :status, :priority, :due_date
  end

  # full task with associations
  view :with_associations do
    fields :title, :status, :priority, :due_date, :created_at, :updated_at

    association :project,  blueprint: ProjectBlueprint, view: :minimal
    association :assignee, blueprint: UserBlueprint
  end
end
