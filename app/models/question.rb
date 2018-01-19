class Question < ApplicationRecord
  belongs_to :group
  has_many :answers, inverse_of: :question, dependent: :destroy
  accepts_nested_attributes_for :answers, reject_if: :all_blank, allow_destroy: true
  has_many :votes, dependent: :destroy
  has_many :users, through: :votes
  has_one :element, dependent: :destroy
  after_save :upd_elm

  def cached_answers
    Rails.cache.fetch([self, "answers"]) {answers.includes(:users).to_a}
  end

  def cached_users
    Rails.cache.fetch([self, "users"]) {users.to_a}
  end

  private

  def upd_elm
    if self.element.present?
      self.element.update(updated_at: Time.now)
    end
  end
  

end
