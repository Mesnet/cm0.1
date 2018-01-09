class CompanyUser < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :company, touch: true

  scope :invited, -> { where(invitation: true) }
  scope :participant, -> { where(participation: true) }
  scope :admin, -> { where(admin: true) }

end
