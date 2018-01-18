class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.integer :cat
      t.integer :effectif
      t.integer :pend_req, default: 0
      t.integer :user_id
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
