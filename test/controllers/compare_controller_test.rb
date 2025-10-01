require "test_helper"

class CompareControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user is redirected to login when accessing compare" do
    get compare_path
    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal "You must be logged in to access this feature.", flash[:auth_required]
  end

  test "authenticated user can access compare page" do
    user = users(:one)
    post session_path, params: { email_address: user.email_address, password: "password" }

    get compare_path
    assert_response :success
  end
end
