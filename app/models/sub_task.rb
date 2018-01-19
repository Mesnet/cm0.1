class SubTask < ApplicationRecord
  belongs_to :task
  belongs_to :user
  belongs_to :doner, optional: true, class_name: "User"
  default_scope {order(done: :asc)} 
  default_scope {order(created_at: :asc)} 
end
