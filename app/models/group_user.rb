class GroupUser < ApplicationRecord
  belongs_to :group, touch: true
  belongs_to :user, touch: true

  scope :favorit, -> { where(favorit: true) }
  scope :unfavorit, -> { where(favorit: false) }
  scope :admin, -> { where(admin: true) }
  scope :invited, -> { where(invitation: true) }
  scope :request, -> { where(request: true) }
  scope :participate, -> { where(participation: true) }
  
end
