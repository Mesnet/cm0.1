class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users


  def cached_company_invitations
    Rails.cache.fetch([self, "cached_company_invitations"]) {(company_users.invited.includes(:company).map(&:company)).to_a}
  end

  def cached_admin_company
    Rails.cache.fetch([self, "cached_admin_company"]) {(company_users.participant.admin.includes(:company).map(&:company)).to_a}
  end


end
