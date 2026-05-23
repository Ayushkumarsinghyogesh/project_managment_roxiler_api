class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.string     :name,        null: false
      t.text       :description
      t.string     :status,      null: false, default: "active"
      t.references :manager,     null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :projects, :status
  end
end
