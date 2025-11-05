class CompareController < ApplicationController
  # Field labels matching the trends controller for consistency
  FIELD_LABELS = {
    "employment_rate_overall" => "Overall Employment Rate (%)",
    "employment_rate_ft_perm" => "Full-Time Permanent Employment Rate (%)",
    "basic_monthly_mean" => "Basic Monthly Salary - Mean (S$)",
    "basic_monthly_median" => "Basic Monthly Salary - Median (S$)",
    "gross_monthly_mean" => "Gross Monthly Salary - Mean (S$)",
    "gross_monthly_median" => "Gross Monthly Salary - Median (S$)",
    "gross_mthly_25_percentile" => "Gross Monthly Salary - 25th Percentile (S$)",
    "gross_mthly_75_percentile" => "Gross Monthly Salary - 75th Percentile (S$)",
    "course_duration" => "Course Duration (Years)"
  }.freeze

  def index
    # Get visualizable fields from CourseStat model
    excluded_columns = %w[id year course_id created_at updated_at]
    @vis_fields = CourseStat.column_names.reject { |col| excluded_columns.include?(col) }

    # Add course_duration from Course model
    @vis_fields << "course_duration"

    # Create field options with labels
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
      end.sort_by { |c| [c[:university], c[:school], c[:degree]] }
    else
      @courses = []
    end

    # Academic years
    @academic_years = (2013..2023).to_a.reverse
  end

  # API endpoint to fetch comparison data for selected courses
  def data
    course_ids = params[:course_ids]&.split(",")&.map(&:to_i) || []
    year = params[:year]&.to_i
    fields = params[:fields]&.split(",") || []

    if course_ids.empty? || !year || fields.empty?
      render json: { error: "Missing required parameters" }, status: :bad_request
      return
    end

    # Fetch course stats for the selected courses and year
    courses_data = Course.where(id: course_ids).includes(:course_stats).map do |course|
      # Find the stats for the specified year
      stat = course.course_stats.find { |cs| cs.year == year }

      # Get previous year's stat - find the most recent year before the selected year
      prev_stat = course.course_stats
                        .select { |cs| cs.year < year }
                        .max_by(&:year)

      course_info = {
        id: course.id,
        university: course.university,
        school: course.school,
        degree: course.degree,
        logo_url: get_university_logo(course.university),
        stats: {}
      }

      # Add requested fields with current and previous values
      fields.each do |field|
        # Handle course_duration separately as it's from Course model, not CourseStat
        if field == "course_duration"
          course_info[:stats][field] = {
            current: course.course_duration,
            previous: nil,
            change: nil
          }
          next
        end

        next unless CourseStat.column_names.include?(field)

        current_value = stat&.send(field)
        previous_value = prev_stat&.send(field)

        course_info[:stats][field] = {
          current: current_value,
          previous: previous_value,
          previous_year: prev_stat&.year,
          change: calculate_change(current_value, previous_value)
        }
      end

      course_info
    end

    render json: courses_data
  end

  private

  def get_university_logo(university)
    logo_map = {
      "Nanyang Technological University" => "ntu_logo.png",
      "National University of Singapore" => "nus_logo.png",
      "Singapore Management University" => "smu_logo.jpg",
      "Singapore University of Technology and Design" => "sutd_logo.png",
      "Singapore Institute of Technology" => "sit_logo.jpg",
      "Singapore University of Social Sciences" => "suss_logo.png"
    }

    logo_file = logo_map[university]
    logo_file ? ActionController::Base.helpers.asset_path(logo_file) : nil
  end

  def calculate_change(current, previous)
    return nil if current.nil? || previous.nil?

    current_f = current.to_f
    previous_f = previous.to_f

    return nil if previous_f.zero?

    change = current_f - previous_f
    {
      direction: change > 0 ? "up" : (change < 0 ? "down" : "same"),
      value: change.abs.round(2)
    }
  end
end
