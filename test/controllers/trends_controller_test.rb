require "test_helper"

class TrendsControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user is redirected to login when accessing trends" do
    get trends_path
    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal "You must be logged in to access this feature.", flash[:auth_required]
  end

  test "authenticated user can access trends page" do
    user = users(:one)
    post session_path, params: { email_address: user.email_address, password: "password" }

    get trends_path
    assert_response :success
  end
end
