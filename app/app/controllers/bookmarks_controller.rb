class BookmarksController < ApplicationController
  def index
    @courses = Current.user.courses.includes(:course_summary)
  end

  def create
    begin
      Bookmark.create(course_id: params[:course_id], user: Current.user)
    rescue
      Bookmark.find_by(course_id: params[:course_id], user: Current.user).destroy
    end

    render partial: "course", locals: { course: Course.includes(:course_summary).find(params[:course_id]) }
  end
end
