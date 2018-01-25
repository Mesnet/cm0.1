class Post < ApplicationRecord
  belongs_to :group
  belongs_to :user
  has_many :elements, dependent: :destroy

  default_scope {order(upd_at: :desc)}

  def cached_user
    Rails.cache.fetch([self, "cached_user"]) {user}
  end

end
