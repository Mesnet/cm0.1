class CompanyUser < ApplicationRecord
  belongs_to :user, touch: true, optional: true
  belongs_to :company, touch: true
  before_create :set_user

  scope :invited, -> { where(invitation: true) }
  scope :participant, -> { where(participation: true) }
  scope :admin, -> { where(admin: true) }
  scope :unregistred, -> { where(user_id: nil) }

  private

  def set_user
    if self.email?
      user = User.find_by(email: self.email)
      if user != nil
        self.user_id = user.id
      end
    end
  end

end
