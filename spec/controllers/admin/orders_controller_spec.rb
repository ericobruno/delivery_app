require 'rails_helper'

RSpec.describe Admin::OrdersController, type: :controller do
  let(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'password123') }
  let(:customer) { Customer.create!(name: 'Test Customer', phone: '123456789') }
  let(:category) { Category.create!(name: 'Test Category') }
  let(:product) { Product.create!(name: 'Test Product', price: 10.99, category: category) }
  let(:order) { Order.create!(customer: customer, status: 'novo', scheduled_for: 1.hour.from_now) }
  let(:valid_attributes) do
    {
      customer_id: customer.id,
      status: 'novo',
      scheduled_for: 2.hours.from_now,
      scheduled_notes: 'Test notes',
      order_items_attributes: [
        { product_id: product.id, quantity: 2, price: 10.99 }
      ]
    }
  end
  let(:invalid_attributes) { { customer_id: nil, status: 'invalid_status' } }

  before do
    sign_in user
    order.order_items.create!(product: product, quantity: 1, price: 10.99)
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @orders' do
      get :index
      expect(assigns(:orders)).to include(order)
    end

    it 'filters by status' do
      other_order = Order.create!(customer: customer, status: 'entregue', scheduled_for: 1.hour.from_now)
      other_order.order_items.create!(product: product, quantity: 1, price: 10.99)
      
      get :index, params: { status: 'novo' }
      expect(assigns(:orders)).to include(order)
      expect(assigns(:orders)).not_to include(other_order)
    end

    it 'searches by customer name' do
      other_customer = Customer.create!(name: 'Other Customer', phone: '987654321')
      other_order = Order.create!(customer: other_customer, status: 'novo', scheduled_for: 1.hour.from_now)
      other_order.order_items.create!(product: product, quantity: 1, price: 10.99)
      
      get :index, params: { search: 'Test' }
      expect(assigns(:orders)).to include(order)
      expect(assigns(:orders)).not_to include(other_order)
    end
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, params: { id: order.id }
      expect(response).to be_successful
    end

    it 'assigns the requested order' do
      get :show, params: { id: order.id }
      expect(assigns(:order)).to eq(order)
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new order with order items' do
      get :new
      expect(assigns(:order)).to be_a_new(Order)
      expect(assigns(:order).order_items).not_to be_empty
    end
  end

  describe 'GET #edit' do
    it 'returns a successful response' do
      get :edit, params: { id: order.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with automatic acceptance enabled' do
      before do
        Setting.set('aceite_automatico', 'on')
      end

      it 'creates order with novo status' do
        post :create, params: { order: valid_attributes }
        expect(Order.last.status).to eq('novo')
      end
    end

    context 'with automatic acceptance disabled' do
      before do
        Setting.set('aceite_automatico', 'off')
      end

      it 'creates order with ag_aprovacao status' do
        post :create, params: { order: valid_attributes }
        expect(Order.last.status).to eq('ag_aprovacao')
      end
    end

    context 'with valid parameters' do
      it 'creates a new Order' do
        expect {
          post :create, params: { order: valid_attributes }
        }.to change(Order, :count).by(1)
      end

      it 'creates order items' do
        expect {
          post :create, params: { order: valid_attributes }
        }.to change(OrderItem, :count).by(1)
      end

      it 'redirects to the order' do
        post :create, params: { order: valid_attributes }
        expect(response).to redirect_to(admin_order_path(Order.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Order' do
        expect {
          post :create, params: { order: invalid_attributes }
        }.to change(Order, :count).by(0)
      end

      it 'renders the new template' do
        post :create, params: { order: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { scheduled_notes: 'Updated notes', status: 'em_preparacao' } }

      it 'updates the requested order' do
        patch :update, params: { id: order.id, order: new_attributes }
        order.reload
        expect(order.scheduled_notes).to eq('Updated notes')
        expect(order.status).to eq('em_preparacao')
      end

      it 'redirects to the order' do
        patch :update, params: { id: order.id, order: new_attributes }
        expect(response).to redirect_to(admin_order_path(order))
      end
    end

    context 'with invalid parameters' do
      it 'renders the edit template' do
        patch :update, params: { id: order.id, order: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested order' do
      order
      expect {
        delete :destroy, params: { id: order.id }
      }.to change(Order, :count).by(-1)
    end

    it 'redirects to the orders list' do
      delete :destroy, params: { id: order.id }
      expect(response).to redirect_to(admin_orders_path)
    end
  end

  describe 'PATCH #accept' do
    context 'when order is awaiting approval' do
      before do
        order.update!(status: 'ag_aprovacao')
      end

      it 'changes status to novo' do
        patch :accept, params: { id: order.id }
        order.reload
        expect(order.status).to eq('novo')
      end

      it 'redirects with success message' do
        patch :accept, params: { id: order.id }
        expect(response).to redirect_to(admin_order_path(order))
        expect(flash[:notice]).to include('aceito com sucesso')
      end
    end

    context 'when order is not awaiting approval' do
      before do
        order.update!(status: 'novo')
      end

      it 'does not change status' do
        original_status = order.status
        patch :accept, params: { id: order.id }
        order.reload
        expect(order.status).to eq(original_status)
      end

      it 'redirects with error message' do
        patch :accept, params: { id: order.id }
        expect(response).to redirect_to(admin_order_path(order))
        expect(flash[:alert]).to include('não está aguardando aprovação')
      end
    end
  end

  describe 'GET #confirm_destroy' do
    it 'returns a successful response' do
      get :confirm_destroy, params: { id: order.id }
      expect(response).to be_successful
    end

    it 'assigns the order' do
      get :confirm_destroy, params: { id: order.id }
      expect(assigns(:order)).to eq(order)
    end
  end
end 