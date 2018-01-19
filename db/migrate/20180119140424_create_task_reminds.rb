class CreateTaskReminds < ActiveRecord::Migration[5.1]
  def change
    create_table :task_reminds do |t|
      t.boolean :deleted_state, default: false
      t.references :task, foreign_key: true
      t.references :user, foreign_key: true
      t.datetime :date
      t.timestamps
    end
  end
end
