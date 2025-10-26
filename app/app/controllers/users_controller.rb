class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  before_action :get_user, only: [ :update ]

  def index
    @user = User.find(Current.session.user_id)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(signup_params)
    if @user.save
      start_new_session_for @user
      redirect_to root_path
    else
      # display error message if fail, repopulate the parameters for username/email but clear password fields
      error_message = @user.errors.full_messages.first
      redirect_to new_user_path(user: signup_params.except(:password, :password_confirmation)), flash: { inline_alert: error_message }
    end
  end

  def update
    if @user.update(profile_params)
      redirect_to users_path, notice: "Profile saved successfully!"
    else
      flash.now[:alert] = "Failed to update profile. Please try again"
      render :index, status: :unprocessable_entity
    end
  end

  private
  def get_user
    @user = User.find(Current.session.user_id)
  end

  def signup_params
    params.expect(user: [ :username, :email_address, :password, :password_confirmation ])
  end

  def profile_params
    params.expect(user: [ :username, :course, :institution, :year_of_study, :interests ])
  end
end
