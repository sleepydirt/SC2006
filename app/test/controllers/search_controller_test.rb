require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user can access search page" do
    get search_path
    assert_response :success
    assert_select "body", /.*/
  end

  test "authenticated user can access search page" do
    user = users(:one)
    post session_path, params: { email_address: user.email_address, password: "password" }

    get search_path
    assert_response :success
  end
end
