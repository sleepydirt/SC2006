# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "csv"

data = File.read(Rails.root.join("db", "cleaned_data.csv"))
data = CSV.parse(data, headers: :true)

data.each do |row|
  c = Course.create(row.to_h.slice("university", "school", "degree", "course_duration")) rescue nil
end

data.each do |row|
  row = row.to_h

  course = Course.find_by(row.slice("university", "school", "degree"))

  row.delete("university")
  row.delete("school")
  row.delete("degree")
  row.delete("course_duration")
  row["course"] = course

  CourseStat.create(row)
end

# build coursesummary from latest coursestat
Course.find_each do |course|
  # Get the latest course stat by year
  latest_stat = course.course_stats.order(year: :desc).first
  
  next unless latest_stat
  
  # calculate salary range from 25pctl-75pctl
  percentile_25 = latest_stat.gross_mthly_25_percentile.to_f
  percentile_75 = latest_stat.gross_mthly_75_percentile.to_f

  CourseSummary.find_or_create_by(course: course) do |summary|
    summary.year = latest_stat.year
    summary.salary_range_min = percentile_25
    summary.salary_range_max = percentile_75
    summary.employment_rate_overall = latest_stat.employment_rate_overall.to_f
    
  end
end
