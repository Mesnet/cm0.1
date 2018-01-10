class Company < ApplicationRecord
  has_many :company_users, dependent: :destroy
  has_many :users, through: :company_users

  def cached_admins
    Rails.cache.fetch([self, "cached_admins"]) {(company_users.participant.admin.includes(:user).map(&:user)).to_a}
  end

  def cached_users
    Rails.cache.fetch([self, "cached_users"]) {(company_users.participant.includes(:user).map(&:user)).to_a}
  end

  def cached_invits
    Rails.cache.fetch([self, "cached_invits"]) {(company_users.invited.includes(:user).map(&:user)).to_a}
  end

end
