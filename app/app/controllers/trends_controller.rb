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

    # Only load unique universities, schools, and degrees for dropdowns
    @universities = Course.select(:university).distinct.order(:university).pluck(:university)

    # Get unique university-school combinations for faster filtering
    @university_schools = Course.select(:university, :school).distinct.map do |c|
      { university: c.university, school: c.school }
    end.group_by { |item| item[:university] }

    # Get unique university-school-degree combinations
    @school_degrees = Course.select(:university, :school, :degree).distinct.map do |c|
      { university: c.university, school: c.school, degree: c.degree }
    end.group_by { |item| "#{item[:university]}|#{item[:school]}" }
  end

  # API endpoint to fetch filtered data
  # The prev approach loaded the entire database into a variable programs, it is fine since our dataset has only ~1000 rows, but in practice its better to only retrieve from the db when necessary
  # We can potentially reuse this later on when creating the Compare page and retrieve via this endpoint, this is just a hack for now
  def data
    university = params[:university]
    school = params[:school]
    degrees = params[:degrees]&.split(",") || []
    field = params[:field]

    # Build the query
    query = CourseStat.includes(:course)
                      .where(courses: { university: university, school: school })

    query = query.where(courses: { degree: degrees }) if degrees.any?

    # Get visualizable fields
    excluded_columns = %w[id year course_id created_at updated_at]
    vis_fields = CourseStat.column_names.reject { |col| excluded_columns.include?(col) }

    # Map the results
    programs = query.map do |stat|
      program_data = {
        university: stat.course.university,
        school: stat.course.school,
        degree: stat.course.degree,
        year: stat.year
      }

      # Only include the requested field to reduce payload size
      program_data[field.to_sym] = stat.send(field).to_f if field && vis_fields.include?(field)

      program_data
    end

    render json: programs
  end
end
