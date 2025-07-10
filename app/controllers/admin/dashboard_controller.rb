class Admin::DashboardController < ApplicationController
  include DashboardFilterable

  def index
    @orders = filter_orders_by_date
    @statuses = Order.distinct.pluck(:status).compact
    @orders_by_status = get_orders_by_status(@orders)
    @filtered_orders = get_filtered_orders(@orders)

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
    
    # Garantir que a setting existe
    unless Setting.exists?(key: 'aceite_automatico')
      Setting.create!(key: 'aceite_automatico', value: 'off')
    end
    
    Setting.set('aceite_automatico', new_status)
    
    # Forçar reload do cache
    Setting.aceite_automatico_force_reload!
    
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
