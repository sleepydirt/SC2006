class UsersController < ApplicationController
  allow_unauthenticated_access only: [:new, :create]

  def index
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
      render :new
    end
  end

  private
  def user_params
    params.expect(user: [:username, :email_address, :password, :password_confirmation])
  end
end
