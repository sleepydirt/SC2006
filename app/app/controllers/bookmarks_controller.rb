class BookmarksController < ApplicationController
  def index
    @courses = Current.user.courses
  end

  def create
    begin
      Bookmark.create(course_id: params[:course_id], user: Current.user)
    rescue
      Bookmark.find_by(course_id: params[:course_id], user: Current.user).destroy
    end
  end
end
