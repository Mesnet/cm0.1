class Task < ApplicationRecord
  belongs_to :group
  belongs_to :doner, optional: true, class_name: "User"
  has_many :task_users, dependent: :destroy
  has_many :users, through: :task_users
  has_many :elements
  has_many :posts, through: :elements
  has_many :task_reminds, dependent: :destroy
  has_many :sub_tasks, dependent: :destroy

  default_scope {order(done_at: :desc)} 
  default_scope {order(priority: :asc)} 
  default_scope {order(date: :asc)} 

  scope :undone, -> {where(done: [false])}
  scope :done, -> {where(done: [true])}

  def cached_users
    Rails.cache.fetch([self, "users"]) {users.to_a}
  end

  def cached_reminds
    Rails.cache.fetch([self, "task_reminds"]) {task_reminds}
  end

  def cached_reminders
    Rails.cache.fetch([self, "reminders"]) {(task_reminds.includes(:user).map(&:user)).to_a}
  end

  def cached_subtasks
    Rails.cache.fetch([self, "subtasks"]) {sub_tasks.to_a}
  end

end
