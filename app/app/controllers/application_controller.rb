class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :check_profile_completion_notice, if: :authenticated?

  private

  def check_profile_completion_notice
    # Only show notice if not on the profile page itself
    return if controller_name == "users" && action_name == "index"
    
    if Current.user
      helper = Object.new.extend(ApplicationHelper)
      unless helper.profile_complete?(Current.user)
        flash.now[:notice] = "New to CareerCompass? Complete your profile now and check out our user guide!"
      end
    end
  end
end
