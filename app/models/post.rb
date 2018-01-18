class Post < ApplicationRecord
  belongs_to :group
  belongs_to :user
  has_many :elements, dependent: :destroy
end
