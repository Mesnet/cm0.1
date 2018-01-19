class Element < ApplicationRecord
  belongs_to :group
  belongs_to :user
  belongs_to :post, touch: true, optional: true
  belongs_to :question, optional: true
  scope :empty, -> { where(post_id: nil) }
  
end
