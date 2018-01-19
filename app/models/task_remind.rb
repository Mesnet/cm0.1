class TaskRemind < ApplicationRecord
  before_destroy :upd_user
  belongs_to :task
  belongs_to :user
  default_scope {order(date: :asc)} 
  scope :active, -> { where(deleted_state: false) }

  private 

  def upd_user
    unless self.deleted_state?
      self.user.update(updated_at: Time.now)
    end
    unless self.task == nil
      self.task.update(updated_at: Time.now)
    end
  end
end
