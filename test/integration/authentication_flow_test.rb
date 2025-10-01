require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  test "complete authentication flow: create account, login, access protected pages, and delete account" do
    # create a new test account
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          username: "test",
          email_address: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    test_user = User.find_by(email_address: "test@example.com")
    assert_not_nil test_user, "User should be created"

    # log out if automatically logged in after registration
    delete logout_path rescue nil

    # login with the test account
    post session_path, params: {
      email_address: "test@example.com",
      password: "password123"
    }

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success

    # access protected pages as authenticated user
    get trends_path
    assert_response :success, "Authenticated user should access trends page"

    get compare_path
    assert_response :success, "Authenticated user should access compare page"

    test_user.destroy if test_user
  end

  test "login with invalid credentials shows error" do
    post session_path, params: {
      email_address: "blabla@example.com",
      password: "password123"
    }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal "Wrong email or password!", flash[:alert]
  end

  test "unauthenticated user can access search but not trends or compare" do
    get search_path
    assert_response :success

    # should be redirected when trying to access trends
    get trends_path
    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal "You must be logged in to access this feature.", flash[:auth_required]

    # should be redirected when trying to access compare
    get compare_path
    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal "You must be logged in to access this feature.", flash[:auth_required]
  end
end
