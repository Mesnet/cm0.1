class Group < ApplicationRecord
  after_create :first_user

  belongs_to :company, optional: true
  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users

  scope :findable, -> {where(cat: [3, 4])}
  scope :perso, -> { where(cat: 2) }

  def cached_users
    Rails.cache.fetch([self, "users"]) {group_users.participate.includes(:user).map(&:user)}
  end

  def cached_requests
    Rails.cache.fetch([self, "requests"]) {(group_users.request.includes(:user).map(&:user)).to_a}
  end

  def cached_invitations
    Rails.cache.fetch([self, "invitation"]) {(group_users.invited.includes(:user).map(&:user)).to_a}
  end

  def cached_admins
    Rails.cache.fetch([self, "admins"]) {(group_users.participate.admin.includes(:user).map(&:user)).to_a}
  end
  

  protected 

  def first_user
    gu = GroupUser.create!(user_id: self.user_id, group_id: self.id, participation: true, admin: true)
    if self.company_id != nil
      if self.company.groups.size == 1
        gu.update(favorit: true)
      end
    end
  end


end
