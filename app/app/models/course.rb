class Course < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_degree,
    against: :degree,
    using: {
      tsearch: { dictionary: "english" }
    },
    ranked_by: ":trigram"
end
