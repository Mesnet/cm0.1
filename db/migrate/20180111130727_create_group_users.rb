class CreateGroupUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :group_users do |t|
      t.references :group, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :favorit, default: false
      t.boolean :request, default: false
      t.boolean :invitation, default: false
      t.boolean :participation, default: false
      t.boolean :admin, default: false
      t.integer :invitor_id
      t.timestamps
    end
  end
end
