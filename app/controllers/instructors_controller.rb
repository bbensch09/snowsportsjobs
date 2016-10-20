class InstructorsController < ApplicationController
  before_action :set_instructor, only: [:show, :edit, :update, :destroy]
  before_action :confirm_admin_permissions, except: [:create, :new, :show, :edit, :thank_you, :browse]
  before_action :confirm_user_permissions, only: [:edit, :update]
  skip_before_action :authenticate_user!, only: [:new, :create, :thank_you, :browse]


  def verify
    instructor = Instructor.find(params[:id])
    instructor.status = 'Active'
    instructor.save
    redirect_to instructors_path, notice: "Instructor has been verified"
  end

  def revoke
    instructor = Instructor.find(params[:id])
    instructor.status = "Revoked"
    instructor.save
    redirect_to instructors_path, notice: "Instructor privileges have been revoked"
  end

  # GET /instructors
  # GET /instructors.json
  def index
    if current_user.user_type == "Partner"
      @instructors = Location.find(current_user.location_id).instructors.sort {|a,b| b.overall_initial_rank <=> a.overall_initial_rank}
      else
      @instructors = Instructor.all.sort {|a,b| b.id <=> a.id}
    end
  end

  def admin_index
     @instructors = Instructor.all.sort {|a,b| b.id <=> a.id}
  end

  # GET /browse
  # GET /browse.json
  def browse
    @instructors = Instructor.where(status: "Active").sort {|a,b| a.overall_initial_rank <=> b.overall_initial_rank}
  end

  # GET /instructors/1
  # GET /instructors/1.json
  def show
  end

  # GET /instructors/new
  def new
    if current_user.instructor
      @instructor = current_user.instructor
      render 'edit'
      else
      @instructor = Instructor.new
    end
  end

  # GET /instructors/1/edit
  def edit
  end

  def thank_you
  end

  # POST /instructors
  # POST /instructors.json
  def create
    @instructor = Instructor.new(instructor_params)
    @instructor.user_id = current_user.id unless current_user.nil?
    @instructor.status = "new applicant"

    respond_to do |format|
      if @instructor.save
        # ga_test_cid = params[:ga_client_id]
        # puts "The GA ga_client_id is #{ga_test_cid}."
        session[:instructor_id] = @instructor.id
        GoogleAnalyticsApi.new.event('instructor-recruitment', 'new-application-submitted', params[:ga_client_id])
        format.html { render 'thank_you', notice: 'Your instructor application was successfully submitted, you will be contacted shortly. You may also reach out with questions to info@snowschoolers.com' }
        format.json { render action: 'show', status: :created, location: @instructor }
      else
        format.html { render action: 'new' }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instructors/1
  # PATCH/PUT /instructors/1.json
  def update
    respond_to do |format|
      if @instructor.update(instructor_params)
        format.html { redirect_to root_path, notice: 'Your instructor application was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @instructor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instructors/1
  # DELETE /instructors/1.json
  def destroy
    @instructor.destroy
    respond_to do |format|
      format.html { redirect_to instructors_url }
      format.json { head :no_content }
    end
  end

  private
    def confirm_user_permissions
      return if current_user.instructor == @instructor || current_user.email == 'brian@snowschoolers.com'
      redirect_to @instructor, notice: 'You do not have permission to edit this page.'
    end

    def confirm_admin_permissions
      return if current_user.email == 'brian@snowschoolers.com' || current_user.email == 'bbensch@gmail.com' || current_user.user_type == "Partner"
      redirect_to root_path, notice: 'You do not have permission to view that page.'
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_instructor
      @instructor = Instructor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def instructor_params
      params.require(:instructor).permit(:first_name, :last_name, :username, :preferred_locations, :certification, :phone_number, :sport, :bio, :intro, :status, :city, :user_id, :avatar, :how_did_you_hear, :confirmed_certification, location_ids:[])
    end
end
