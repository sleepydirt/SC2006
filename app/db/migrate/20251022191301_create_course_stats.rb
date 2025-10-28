class CreateCourseStats < ActiveRecord::Migration[8.0]
  def change
    create_table :course_stats do |t|
      t.integer :year
      # t.string :university
      # t.string :school
      # t.string :degree
      t.string :employment_rate_overall
      t.string :employment_rate_ft_perm
      t.string :basic_monthly_mean
      t.string :basic_monthly_median
      t.string :gross_monthly_mean
      t.string :gross_monthly_median
      t.string :gross_mthly_25_percentile
      t.string :gross_mthly_75_percentile

      t.belongs_to :course, foreign_key: true

      t.timestamps
    end
  end
end
