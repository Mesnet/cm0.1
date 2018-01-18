class CreateElements < ActiveRecord::Migration[5.1]
  def change
    create_table :elements do |t|
      t.integer :cat
      t.references :group, foreign_key: true
      t.references :post, foreign_key: true
      t.references :user, foreign_key: true
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
