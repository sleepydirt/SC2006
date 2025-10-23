class TrendsController < ApplicationController
  def index
    csv_path = Rails.root.join("assets/data/cleaned_data.csv")
    require "csv"
    @programs = []

    CSV.foreach(csv_path, headers: true) do |row|
      @programs << {
        university: row["university"],
        school: row["school"],
        degree: row["degree"],
        year: row["year"].to_i,
        employment_rate_overall: row["employment_rate_overall"].to_f,
        employment_rate_ft_perm: row["employment_rate_ft_perm"].to_f,
        basic_monthly_mean: row["basic_monthly_mean"].to_f,
        basic_monthly_median: row["basic_monthly_median"].to_f,
        gross_monthly_mean: row["gross_monthly_mean"].to_f,
        gross_monthly_median: row["gross_monthly_median"].to_f,
        gross_mthly_25_percentile: row["gross_mthly_25_percentile"].to_f,
        gross_mthly_75_percentile: row["gross_mthly_75_percentile"].to_f,
        course_duration: row["course_duration"].to_f
      }
    end

    # Unique list of universities for dropdown
    @universities = @programs.map { |p| p[:university] }.uniq.sort

  end
end
