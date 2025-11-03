class CoursesController < ApplicationController
  allow_unauthenticated_access
  def index
    @courses = Course.all
  end

  def show
    @course = Course.find(params[:id])
    @course_stats = @course.course_stats.order(year: :desc)
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

    # Start with all courses
    @courses = Course.includes(:course_summary)

    # Filter by degree keyword if provided and not empty
    if params[:degree].present?
      @courses = @courses
        .select("courses.*, ts_rank_cd(to_tsvector(degree), websearch_to_tsquery('english', '#{params[:degree]}')) AS rank")
        .where("to_tsvector('english', degree) @@ websearch_to_tsquery('english', ?)", params[:degree])
        .order("rank DESC")
    end

    if params[:university].present?
      selected_universities = params[:university].select { |k, v| v == "1" }.keys
      @courses = @courses.where("university IN (?)", selected_universities) if selected_universities.any?
    end

    if params[:salary_min].present? || params[:salary_max].present?
      salary_min = params[:salary_min].to_f
      salary_max = params[:salary_max].to_f
      
      @courses = @courses.joins(:course_summary)
        .where("course_summaries.salary_range_min >= ? AND course_summaries.salary_range_min <= ?", salary_min, salary_max)
        .or(@courses.joins(:course_summary)
          .where("course_summaries.salary_range_max >= ? AND course_summaries.salary_range_max <= ?", salary_min, salary_max))
    end

    if params[:employment_rate_min].present? || params[:employment_rate_max].present?
      employment_min = params[:employment_rate_min].to_f
      employment_max = params[:employment_rate_max].to_f
      
      @courses = @courses.joins(:course_summary)
        .where("course_summaries.employment_rate_overall >= ? AND course_summaries.employment_rate_overall <= ?", employment_min, employment_max)
    end

    @courses = @courses.order("courses.university, courses.degree") unless params[:degree].present?
  end
end
