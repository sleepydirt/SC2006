class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]

  def index
    @user = User.find(Current.session.user_id)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for @user
      redirect_to root_path
    else
      # display error message if fail, repopulate the parameters for username/email but clear password fields
      error_message = @user.errors.full_messages.first
      redirect_to new_user_path(user: user_params.except(:password, :password_confirmation)), flash: { inline_alert: error_message }
    end
  end

  private
  def user_params
    params.expect(user: [ :username, :email_address, :password, :password_confirmation ])
  end
end
