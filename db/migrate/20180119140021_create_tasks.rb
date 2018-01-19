class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.datetime :date
      t.boolean :done, default: false
      t.datetime :done_at
      t.integer :doner_id
      t.boolean :assigned, default: false
      t.integer :st_n, default: 0
      t.integer :st_d, default: 0
      t.integer :effectif, default: 0
      t.integer :priority, default: 3
      t.boolean :important, default: false
      t.references :user, foreign_key: true
      t.references :group, foreign_key: true

      t.timestamps
    end
  end
end
