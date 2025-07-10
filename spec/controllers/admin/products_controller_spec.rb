require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do
  let(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'password123') }
  let(:category) { Category.create!(name: 'Test Category') }
  let(:product) { Product.create!(name: 'Test Product', price: 10.99, category: category) }
  let(:valid_attributes) { { name: 'New Product', price: 15.99, category_id: category.id } }
  let(:invalid_attributes) { { name: '', price: nil } }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @products' do
      product
      get :index
      expect(assigns(:products)).to include(product)
    end

    it 'filters by category' do
      other_category = Category.create!(name: 'Other Category')
      other_product = Product.create!(name: 'Other Product', price: 5.99, category: other_category)
      
      get :index, params: { category_id: category.id }
      expect(assigns(:products)).to include(product)
      expect(assigns(:products)).not_to include(other_product)
    end

    it 'searches by name' do
      other_product = Product.create!(name: 'Different Product', price: 5.99, category: category)
      
      get :index, params: { search: 'Test' }
      expect(assigns(:products)).to include(product)
      expect(assigns(:products)).not_to include(other_product)
    end
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, params: { id: product.id }
      expect(response).to be_successful
    end

    it 'assigns the requested product' do
      get :show, params: { id: product.id }
      expect(assigns(:product)).to eq(product)
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new product' do
      get :new
      expect(assigns(:product)).to be_a_new(Product)
    end
  end

  describe 'GET #edit' do
    it 'returns a successful response' do
      get :edit, params: { id: product.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new Product' do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
      end

      it 'redirects to the product' do
        post :create, params: { product: valid_attributes }
        expect(response).to redirect_to(admin_product_path(Product.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Product' do
        expect {
          post :create, params: { product: invalid_attributes }
        }.to change(Product, :count).by(0)
      end

      it 'renders the new template' do
        post :create, params: { product: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Product', price: 20.99 } }

      it 'updates the requested product' do
        patch :update, params: { id: product.id, product: new_attributes }
        product.reload
        expect(product.name).to eq('Updated Product')
        expect(product.price).to eq(20.99)
      end

      it 'redirects to the product' do
        patch :update, params: { id: product.id, product: new_attributes }
        expect(response).to redirect_to(admin_product_path(product))
      end
    end

    context 'with invalid parameters' do
      it 'renders the edit template' do
        patch :update, params: { id: product.id, product: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when product can be deleted' do
      it 'destroys the requested product' do
        product
        expect {
          delete :destroy, params: { id: product.id }
        }.to change(Product, :count).by(-1)
      end

      it 'redirects to the products list' do
        delete :destroy, params: { id: product.id }
        expect(response).to redirect_to(admin_products_path)
      end
    end

    context 'when product cannot be deleted due to foreign key constraint' do
      let(:customer) { Customer.create!(name: 'Test Customer', phone: '123456789') }
      let(:order) do
        order = Order.new(customer: customer, status: 'novo')
        order.order_items.build(product: product, quantity: 1, price: 10.99)
        order.save!
        order
      end

      it 'does not destroy the product' do
        expect {
          delete :destroy, params: { id: product.id }
        }.to change(Product, :count).by(0)
      end

      it 'redirects with an error message' do
        delete :destroy, params: { id: product.id }
        expect(response).to redirect_to(admin_products_path)
        expect(flash[:alert]).to include('não pode ser excluído')
      end
    end
  end

  describe 'GET #confirm_destroy' do
    it 'returns a successful response' do
      get :confirm_destroy, params: { id: product.id }
      expect(response).to be_successful
    end

    it 'assigns the product' do
      get :confirm_destroy, params: { id: product.id }
      expect(assigns(:product)).to eq(product)
    end
  end
end 