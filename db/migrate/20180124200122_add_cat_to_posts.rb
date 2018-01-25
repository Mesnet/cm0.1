class AddCatToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :title, :string
    add_column :posts, :cat, :integer, default: 2
    add_column :posts, :upd_at, :datetime
    add_column :posts, :upd_title, :string, default: 'a créer un Post'
  end
end
