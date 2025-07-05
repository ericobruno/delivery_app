class Admin::ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy confirm_destroy]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_product_path(@product), notice: 'Produto criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to admin_product_path(@product), notice: 'Produto atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_products_path, notice: 'Produto removido com sucesso.' }
    end
  end

  def confirm_destroy
    # Apenas renderiza o template confirm_destroy.turbo_frame.erb
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :category_id)
  end
end
