class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  def search_results
    if params[:search]
      @search_params = {search_text: params[:search], length: [params[:search_length_1],params[:search_length_2],params[:search_length_3],params[:search_length_6],params[:search_length_7]],status: params[:search_status],slot: params[:search_slot],resort_filter: params[:resort_filter]}
      puts "!!!!! the search_params are: #{@search_params}"
      @products = Product.search(@search_params)
    else
      @products = Product.all.order("price ASC")
    end
    case params[:sort_tag]
      when "Price Low to High"
        @products.sort! {|a,b| a.price <=> b.price}
      when "Price High to Low"
        @products.sort! {|a,b| b.price <=> a.price}
      when "Resort A-Z"
        @products.sort! {|a,b| a.location.name <=> b.location.name}
      else
        @products.sort! {|a,b| a.price <=> b.price}
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :price, :location_id, :calendar_period, :search, :length, :slot, :start_time, :search_length, :search_status, :search_slot, :search_cert, :search_sport, :search_location, :sort_tag)
    end
end
