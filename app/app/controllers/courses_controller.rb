class CoursesController < ApplicationController
  allow_unauthenticated_access
  def index
    @courses = Course.all
  end

  def query
    @courses = Course.search_degree(params[:degree])
  end
end
