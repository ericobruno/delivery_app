class Admin::DashboardController < ApplicationController
  def index
    # Filtro padrão: mostrar pedidos do dia atual
    from = params[:from].present? ? Date.parse(params[:from]) : Date.today
    to = params[:to].present? ? Date.parse(params[:to]) : Date.today

    # Filtro pelo campo scheduled_for
    @orders = Order.where(scheduled_for: from.beginning_of_day..to.end_of_day)
    @statuses = Order.distinct.pluck(:status).compact
    @orders_by_status = @statuses.index_with { |status| @orders.where(status: status).count }
    @filtered_orders = params[:status].present? ? @orders.where(status: params[:status]).order(scheduled_for: :asc).limit(20) : @orders.order(scheduled_for: :asc).limit(20)
    @from = from
    @to = to

    if turbo_frame_request?
      if request.headers["Turbo-Frame"].to_s == "pedidos"
        render partial: 'pedidos_table_frame', locals: { orders: @filtered_orders }
      else
        head :ok
      end
    end
  end

  def toggle_aceite_automatico
    current = Setting.aceite_automatico?
    new_status = params[:status] == 'on' ? 'on' : 'off'
    Setting.set('aceite_automatico', new_status)
    
    respond_to do |format|
      format.json do
        render json: { 
          success: true, 
          status: new_status,
          message: "Aceite automático #{new_status == 'on' ? 'ativado' : 'desativado'}!"
        }
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('aceite-automatico-btn', partial: 'admin/dashboard/aceite_automatico_button')
      end
      format.html { redirect_to admin_root_path, notice: "Aceite automático #{new_status == 'on' ? 'ativado' : 'desativado'}!" }
    end
  end
end
