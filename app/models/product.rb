class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_many :order_items
  has_one_attached :image

  validates :name, presence: true
  validates :price, presence: true
end
