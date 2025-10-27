class BookmarksController < ApplicationController
  def create
    bookmark = Bookmark.create(course_id: params[:course_id], user: Current.user)
  end
end
