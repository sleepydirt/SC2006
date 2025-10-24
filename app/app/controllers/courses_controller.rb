class CoursesController < ApplicationController
  allow_unauthenticated_access
  def index
    @courses = Course.all
  end

  def show
    @course = Course.find(params[:id])
    @course_stats = CourseStat.where(course_id: @course.id).order(year: :desc)
  end

  def query
    @universities = [
      "National University of Singapore",
      "Nanyang Technological University",
      "Singapore Management University",
      "Singapore Institute of Technology",
      "Singapore University of Social Sciences",
      "Singapore University of Technology and Design"
    ]


    if params[:degree]
      @courses = Course
        .select("*, ts_rank_cd(to_tsvector(degree), to_tsquery('english', '#{params[:degree]}')) AS rank")
        .where("to_tsvector('english', degree) @@ to_tsquery('english', ?)", params[:degree])
        .order("rank")
    else
      @courses = Course.all
    end

    if params[:university]
      @courses = @courses.where("university IN (?)", params[:university].select { |k, v| v == "1" }.keys)
    end
  end
end
