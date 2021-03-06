class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :default_value
  after_create :first_group, :assign_elements
  before_save :upd_elements

  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users
  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users

  has_many :posts, dependent: :destroy
  has_many :elements, dependent: :destroy

  has_many :task_users, dependent: :destroy
  has_many :tasks, through: :task_users
  has_many :task_reminds, dependent: :destroy

  #Cache for company system
  def cached_company_invitations
    Rails.cache.fetch([self, "cached_company_invitations"]) {(company_users.invited.includes(:company).map(&:company)).to_a}
  end

  def cached_admin_company
    Rails.cache.fetch([self, "cached_admin_company"]) {(company_users.participant.admin.includes(:company).map(&:company)).to_a}
  end

  #Cache for group system
  def cached_mygroup
    Rails.cache.fetch([self, "my_group"]) {group_users.participate.first.group}
  end

  def cached_mygroupid
    Rails.cache.fetch([self, "mygroupid"]) {self.cached_mygroup.id}
  end

  def cached_group_invitations
    Rails.cache.fetch([self, "group_invitations"]) {(group_users.invited.includes(:group).map(&:group)).to_a}
  end

  def cached_group_requests
    Rails.cache.fetch([self, "group_requests"]) {(group_users.request.includes(:group).map(&:group)).to_a}
  end

  def favgroups
    self.group_users.participate.favorit.includes(:group).map(&:group)
  end

  def unfavgroups
    self.group_users.participate.unfavorit.includes(:group).map(&:group) - [self.cached_mygroup]
  end

  def othergroups
    (self.company.groups.findable - self.favgroups - self.unfavgroups - [self.cached_mygroup])
  end

  #Cache for event system

  def cached_event_invitations
    self.companies - self.companies
  end


  private

  def assign_elements
    CompanyUser.where(email: self.email).update(user_id: self.id)
    self.update(pend_invit: CompanyUser.where(email: self.email).size)
  end

  def default_value
    self.initial = 'CM'
  end

  def first_group
    @group = Group.create!(cat: 1, user_id: self.id)
  end

  def upd_elements
    @first_group = Group.where(cat: 1, user_id: self.id).first
    if self.pseudo_changed?
      @first_group.update(name: self.pseudo)
    end
    # Update all the elements containing the pseudo(for the caches)
  end

end
