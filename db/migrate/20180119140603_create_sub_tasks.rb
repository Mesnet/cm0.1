class CreateSubTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :sub_tasks do |t|
      t.string :title
      t.boolean :done, default: false
      t.datetime :done_at
      t.integer :doner_id
      t.references :task, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
