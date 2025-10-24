class TrendsController < ApplicationController
  def index
    # Get all programs from the database
    @programs = Course.all

    # Convert numeric fields to float (if needed in JS)
    @programs = @programs.map do |p|
      {
        university: p.university,
        school: p.school,
        degree: p.degree,
        year: p.year,
        employment_rate_overall: p.employment_rate_overall.to_f,
        employment_rate_ft_perm: p.employment_rate_ft_perm.to_f,
        basic_monthly_mean: p.basic_monthly_mean.to_f,
        basic_monthly_median: p.basic_monthly_median.to_f,
        gross_monthly_mean: p.gross_monthly_mean.to_f,
        gross_monthly_median: p.gross_monthly_median.to_f,
        gross_mthly_25_percentile: p.gross_mthly_25_percentile.to_f,
        gross_mthly_75_percentile: p.gross_mthly_75_percentile.to_f,
        #course_duration: p.course_duration.to_f
      }
    end

    # Unique list of universities for dropdown
    @universities = Course.select(:university).distinct.order(:university).pluck(:university)
  end
end
