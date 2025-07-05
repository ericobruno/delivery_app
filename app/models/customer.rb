class Customer < ApplicationRecord
  has_many :orders

  validates :name, presence: true
  validates :phone, presence: true
end
