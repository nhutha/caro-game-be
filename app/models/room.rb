class Room < ApplicationRecord
  # Associations
  belongs_to :master, class_name: "User", foreign_key: "master_id", optional: false
  belongs_to :guest, class_name: "User", foreign_key: "guest_id", optional: true
  has_one :game, dependent: :destroy
  
  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
  
  # Enums
  enum :status, { 
    waiting: 0,    # Chờ người chơi thứ 2
    playing: 1,    # Đang chơi
    finished: 2    # Đã kết thúc
  }
  
  # Scopes
  scope :available, -> { where(status: :waiting, guest_id: nil) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Instance methods
  def full?
    guest_id.present?
  end
  
  def can_start?
    full? && waiting?
  end
  
  def players
    [master, guest].compact
  end
end