class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.string :title
      t.integer :voters, default: 0
      t.boolean :multiple, default: false
      t.references :group, foreign_key: true

      t.timestamps
    end
  end
end
