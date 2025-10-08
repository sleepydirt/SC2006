class CoursesController < ApplicationController
  allow_unauthenticated_access
  def index
    @courses = Course.all
  end

  def query
    @courses = Course.where("degree LIKE ?", "%#{params[:degree]}%")
  end
end
