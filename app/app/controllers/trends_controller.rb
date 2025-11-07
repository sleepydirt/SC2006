class TrendsController < ApplicationController
  # Change field labels to look more professional
  # Rubocop may complain about single quotes but putting double quotes break the json
  FIELD_LABELS = {
    "employment_rate_overall" => "Overall Employment Rate (%)",
    "employment_rate_ft_perm" => "Full-Time Permanent Employment Rate (%)",
    "basic_monthly_mean" => "Basic Monthly Salary - Mean (S$)",
    "basic_monthly_median" => "Basic Monthly Salary - Median (S$)",
    "gross_monthly_mean" => "Gross Monthly Salary - Mean (S$)",
    "gross_monthly_median" => "Gross Monthly Salary - Median (S$)",
    "gross_mthly_25_percentile" => "Gross Monthly Salary - 25th Percentile (S$)",
    "gross_mthly_75_percentile" => "Gross Monthly Salary - 75th Percentile (S$)"
  }.freeze

  def index
    # Get visualizable fields from CourseStat model
    # Exclude: id, year, course_id, created_at, updated_at
    excluded_columns = %w[id year course_id created_at updated_at]
    @vis_fields = CourseStat.column_names.reject { |col| excluded_columns.include?(col) }

    # Create field options
    @field_options = @vis_fields.map do |field|
      {
        value: field,
        label: FIELD_LABELS[field]
      }
    end

    # Get bookmarked courses for the current user
    if Current.user
      @courses = Current.user.bookmarks.includes(:course).map do |bookmark|
        course = bookmark.course
        {
          id: course.id,
          university: course.university,
          school: course.school,
          degree: course.degree,
          display_name: "#{course.university} - #{course.degree}"
        }
      end.sort_by { |c| [ c[:university], c[:school], c[:degree] ] }
    else
      @courses = []
    end
  end

  # API endpoint to fetch trends data for selected courses
  def data
    course_ids = params[:course_ids]&.split(",")&.map(&:to_i) || []
    field = params[:field]

    if course_ids.empty? || !field
      render json: { error: "Missing required parameters" }, status: :bad_request
      return
    end

    # Limit to maximum 5 courses
    course_ids = course_ids.first(5)

    # Get visualizable fields
    excluded_columns = %w[id year course_id created_at updated_at]
    vis_fields = CourseStat.column_names.reject { |col| excluded_columns.include?(col) }

    if !vis_fields.include?(field)
      render json: { error: "Invalid field" }, status: :bad_request
      return
    end

    # Build the query to get stats for selected courses
    query = CourseStat.includes(:course)
                      .where(course_id: course_ids)

    # Map the results
    programs = query.map do |stat|
      program_data = {
        course_id: stat.course.id,
        university: stat.course.university,
        school: stat.course.school,
        degree: stat.course.degree,
        year: stat.year
      }

      # Include the requested field
      program_data[field.to_sym] = stat.send(field).to_f

      program_data
    end

    render json: programs
  end
end
