module ApplicationHelper
  def user_profile_subtitle(user)
    if profile_complete?(user)
      "#{user.institution} #{user.course}, Year #{user.year_of_study}"
    else
      "Update profile"
    end
  end

  def profile_complete?(user)
    user.institution.present? && !user.institution.blank? &&
    user.course.present? && !user.course.blank? &&
    user.year_of_study.present?
  end

  def check_profile_completion(user)
    unless profile_complete?(user)
      flash.now[:notice] = "New to CareerCompass? Complete your profile now and check out our user guide"
    end
  end
end
