class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :university
      t.string :school
      t.string :degree
      t.integer :course_duration

      t.timestamps
    end

    add_index :courses, [ :university, :school, :degree ], unique: true
  end
end
