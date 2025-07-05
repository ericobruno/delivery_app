class CreateJoinTableOrderItemProduct < ActiveRecord::Migration[7.1]
  def change
    create_join_table :order_items, :products do |t|
      # t.index [:order_item_id, :product_id]
      # t.index [:product_id, :order_item_id]
    end
  end
end
