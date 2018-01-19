class Post < ApplicationRecord
  belongs_to :group
  belongs_to :user
  has_many :elements, dependent: :destroy

  def cached_user
    Rails.cache.fetch([self, "cached_user"]) {user}
  end
end
