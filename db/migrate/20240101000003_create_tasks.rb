class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string     :title,      null: false
      t.string     :status,     null: false, default: "pending"
      t.string     :priority,   default: "medium"
      t.date       :due_date
      t.references :project,    null: false, foreign_key: true
      t.references :assignee,   null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, :priority
    add_index :tasks, [ :project_id, :title ], unique: true, name: "index_tasks_on_project_and_title"
  end
end
