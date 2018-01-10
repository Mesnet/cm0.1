class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  after_create :verif_exist

  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users


  def cached_company_invitations
    Rails.cache.fetch([self, "cached_company_invitations"]) {(company_users.invited.includes(:company).map(&:company)).to_a}
  end

  def cached_admin_company
    Rails.cache.fetch([self, "cached_admin_company"]) {(company_users.participant.admin.includes(:company).map(&:company)).to_a}
  end

  private

  def verif_exist
    pre_user = User.where(email: self.email).first
    if pre_user != nil && pre_user.registred != true && pre_user.id != self.id
      pre_user.update(encrypted_password: self.encrypted_password, created_at: self.created_at, registred: true)
      self.destroy
    end
  end


end
