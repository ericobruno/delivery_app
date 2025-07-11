class Admin::DashboardController < ApplicationController
  include DashboardFilterable

  def index
    @orders = filter_orders_by_date
    @statuses = Order.distinct.pluck(:status).compact
    @orders_by_status = get_orders_by_status(@orders)
    @filtered_orders = get_filtered_orders(@orders)
    
    # Para o kanban, precisamos de todos os pedidos (não limitados)
    @kanban_orders = @orders.includes(:customer, :order_items => :product).order(created_at: :desc)

    if turbo_frame_request?
      if request.headers["Turbo-Frame"].to_s == "pedidos"
        render partial: 'kanban_board_frame', locals: { orders: @kanban_orders }
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
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('aceite-automatico-btn', partial: 'admin/dashboard/aceite_automatico_button'),
          turbo_stream.update('flash-messages', partial: 'shared/flash', locals: { 
            notice: "Aceite automático #{new_status == 'on' ? 'ativado' : 'desativado'} com sucesso!" 
          })
        ]
      end
      format.json do
        render json: { 
          success: true, 
          status: new_status,
          message: "Aceite automático #{new_status == 'on' ? 'ativado' : 'desativado'}!"
        }
      end
      format.html { 
        redirect_to admin_root_path, 
        notice: "Aceite automático #{new_status == 'on' ? 'ativado' : 'desativado'}!" 
      }
    end
  end
end
