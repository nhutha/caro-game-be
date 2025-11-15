class Room < ApplicationRecord
  belongs_to :master, class_name: "User", foreign_key: "master_id", optional: false
  belongs_to :guest, class_name: "User", foreign_key: "guest_id", optional: true
end