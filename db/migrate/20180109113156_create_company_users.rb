class CreateCompanyUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :company_users do |t|
      t.integer :admin, default: false
      t.boolean :invitation, default: false
      t.boolean :participation, default: false
      t.string :email
      t.references :user, foreign_key: true
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
