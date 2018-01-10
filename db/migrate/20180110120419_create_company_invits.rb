class CreateCompanyInvits < ActiveRecord::Migration[5.1]
  def change
    create_table :company_invits do |t|
      t.string :email
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
