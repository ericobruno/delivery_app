class AddScheduledForToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :scheduled_for, :datetime
    add_column :orders, :scheduled_notes, :text
  end
end
