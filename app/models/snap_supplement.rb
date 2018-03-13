class SnapSupplement < ApplicationRecord
  has_many :members,
    -> { order "created_at" },
    class_name: "HouseholdMember",
    foreign_key: "snap_supplement_id"
end
