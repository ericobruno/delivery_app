module DashboardFilterable
  extend ActiveSupport::Concern

  private

  def filter_orders_by_date
    from = params[:from].present? ? Date.parse(params[:from]) : Date.today
    to = params[:to].present? ? Date.parse(params[:to]) : Date.today
    
    @from = from
    @to = to
    
    Order.where(scheduled_for: from.beginning_of_day..to.end_of_day)
  end

  def get_orders_by_status(orders)
    statuses = Order.distinct.pluck(:status).compact
    statuses.index_with { |status| orders.where(status: status).count }
  end

  def get_filtered_orders(orders, limit: 20)
    filtered = params[:status].present? ? orders.where(status: params[:status]) : orders
    filtered.order(scheduled_for: :asc).limit(limit)
  end
end