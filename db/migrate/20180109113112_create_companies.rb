class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.integer :size_type
      t.integer :effectif, default: 1

      t.timestamps
    end
  end
end
