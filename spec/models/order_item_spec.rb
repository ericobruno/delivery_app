require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  it { should belong_to(:order) }
  it { should belong_to(:product) }
  it { should have_and_belong_to_many(:additional_products).class_name('Product').join_table('order_items_products') }
end 