class Answer < ApplicationRecord
  belongs_to :question, touch: true
  has_many :votes, dependent: :destroy
  has_many :users, through: :votes

  def cached_voters
    Rails.cache.fetch([self, "voters"]) {users.to_a}
  end

end
