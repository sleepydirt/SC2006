class Course < ApplicationRecord
  has_many :course_stats
  has_one :course_summary
  has_many :users, through: :bookmarks

  include PgSearch::Model
  pg_search_scope :search_degree,
    against: :degree,
    using: {
      tsearch: { dictionary: "english" }
    },
    ranked_by: ":trigram"
end
