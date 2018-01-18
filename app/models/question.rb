class Question < ApplicationRecord
  belongs_to :group
  has_many :answers, inverse_of: :question, dependent: :destroy
  accepts_nested_attributes_for :answers, reject_if: :all_blank, allow_destroy: true
  has_many :votes, dependent: :destroy
  has_many :users, through: :votes
  has_one :element, dependent: :destroy

end
