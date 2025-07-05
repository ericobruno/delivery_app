class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  has_and_belongs_to_many :additional_products, class_name: 'Product', join_table: 'order_items_products'
  validates :product, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
