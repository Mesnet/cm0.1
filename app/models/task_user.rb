class TaskUser < ApplicationRecord
  belongs_to :task, touch: true
  belongs_to :user, touch: true

end
