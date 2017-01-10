class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update]
  before_action :find_user, except: [:index, :new, :create]
  before_action :correct_user, only: [:edit, :update]
  before_action :verify_admin, only: :destroy

  def index
    @users = User.paginate page: params[:page]
  end

  def show
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.order_desc.paginate page: params[:page]
    unless @user.current_user? current_user
      @relation = if current_user.following? @user
        current_user.active_relationships.find_by followed_id: @user.id
      else
        current_user.active_relationships.build
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def correct_user
    unless @user.current_user? current_user
      flash[:danger] = "Your can't edit other user's infomation"
      redirect_to root_url
    end
  end

  def find_user
    @user = User.find_by id: params[:id]
    if @user.nil?
      flash[:danger] = "User not found"
      redirect_to root_path
    end
  end
  
  private
  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def verify_admin
    redirect_to root_url unless current_user.admin?
  end
end
