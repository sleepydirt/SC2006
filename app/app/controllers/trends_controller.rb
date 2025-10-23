class TrendsController < ApplicationController
  def index
    csv_path = Rails.root.join("app/assets/data/cleaned_data.csv")
    require "csv"
    @programs = []

    CSV.foreach(csv_path, headers: true) do |row|
      @programs << {
        university: row["university"],
        school: row["school"],
        degree: row["degree"],
        employment_rate_overall: row["employment_rate_overall"],
        employment_rate_ft_perm: row["employment_rate_ft_perm"],
        basic_monthly_mean: row["basic_monthly_mean"],
        basic_monthly_median: row["basic_monthly_median"],
        gross_monthly_mean: row["gross_monthly_mean"],
        gross_monthly_median: row["gross_monthly_median"],
        gross_mthly_25_percentile: row["gross_mthly_25_percentile"],
        gross_mthly_75_percentile: row["gross_mthly_75_percentile"],
        course_duration: row["course_duration"]
      }
    end

    # Add unique lists for filters
    @universities = @programs.map { |p| p[:university] }.uniq.sort
  end
end
