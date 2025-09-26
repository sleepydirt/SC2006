class CoursesController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    @courses = Course.all
  end
end
