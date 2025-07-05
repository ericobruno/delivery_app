class Admin::CategoriesController < ApplicationController
  before_action :set_category, only: %i[show edit update destroy]

  def index
    @categories = Category.all
  end

  def show
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace('categoria-select', partial: 'admin/products/categoria_select', locals: { form: form_for_product, selected: @category.id }),
            turbo_stream.remove('modal-categoria')
          ]
        }
        format.html { redirect_to admin_category_path(@category), notice: 'Categoria criada com sucesso.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_category_path(@category), notice: 'Categoria atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_path, notice: 'Categoria removida com sucesso.'
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end

  # Helper para passar o form correto ao turbo_stream
  def form_for_product
    view_context.form_with(model: [:admin, Product.new], local: true, class: 'row g-3', html: { multipart: true }) do |form|
      form
    end
  end
end
