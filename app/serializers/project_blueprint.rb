class ProjectBlueprint < Blueprinter::Base
  identifier :id

  # minimal — used inside task responses to avoid circular nesting
  view :minimal do
    fields :name, :status, :description
  end

  # default — project list + show with full task+assignee nesting
  view :with_tasks do
    fields :name, :description, :status, :created_at, :updated_at

    association :manager, blueprint: UserBlueprint

    association :tasks, blueprint: TaskBlueprint, view: :minimal do |project, _options|
      project.tasks
    end

    field :task_count do |project, _options|
      project.tasks.size
    end
  end
end
