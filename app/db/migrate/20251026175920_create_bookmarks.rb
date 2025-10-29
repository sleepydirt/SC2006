class CreateBookmarks < ActiveRecord::Migration[8.0]
  def change
    create_table :bookmarks do |t|
      t.belongs_to :user
      t.belongs_to :course

      t.timestamps
    end

    add_index :bookmarks, [ :user_id, :course_id ], unique: true
  end
end
