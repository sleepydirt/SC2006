class CourseStatsController < ApplicationController
  allow_unauthenticated_access

  def index
    @course_stats = CourseStat.all
  end
end
