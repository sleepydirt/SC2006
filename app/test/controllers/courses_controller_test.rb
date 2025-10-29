require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user can access search page" do
    get courses_query_path
    assert_response :success
    assert_select "body", /.*/
  end

  test "authenticated user can access search page" do
    user = users(:one)
    post session_path, params: { email_address: user.email_address, password: "password" }

    get courses_query_path
    assert_response :success
  end
end
