class CreateCourseSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :course_summaries do |t|
      t.integer :year
      t.decimal :salary_range_min
      t.decimal :salary_range_max
      t.decimal :employment_rate_overall
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
