class AddAttributesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :course, :string
    add_column :users, :institution, :string
    add_column :users, :interests, :string
    add_column :users, :year_of_study, :integer
  end
end
