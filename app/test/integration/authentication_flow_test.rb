require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  # basis path 1: create user with valid parameters
  test "user registration with valid parameters" do
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          username: "testuser",
          email_address: "testuser@example.com",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_redirected_to root_path
    test_user = User.find_by(email_address: "testuser@example.com")
    assert_not_nil test_user, "User should be created successfully"
    test_user.destroy if test_user
  end

  # basis path 2: user registration with invalid params
  test "user registration with invalid parameters fails" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          username: "",
          email_address: "invalid-email",
          password: "123",
          password_confirmation: "456"
        }
      }
    end


    assert_response :redirect
    follow_redirect!
    # check for an alert
    assert_not_nil flash[:inline_alert]
  end

  # basis path 3: create user with valid credentials and log in successfully
  test "login with correct credentials succeeds" do
    # Create test user
    user = User.create!(
      username: "logintest",
      email_address: "logintest@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    # ensure logged out
    delete logout_path

    # attempt login with correct credentials
    post session_path, params: {
      email_address: "logintest@example.com",
      password: "Password123!"
    }

    assert_response :redirect
    follow_redirect!
    # after login, should be able to access protected pages
    get bookmarks_path
    assert_response :success, "Should be able to access protected page after login"
    user.destroy
  end

  # basis path 4: login with incorrect password fails
  test "login with incorrect password fails" do
    user = User.create!(
      username: "wrongpasstest",
      email_address: "wrongpasstest@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    # ensure logged out
    delete logout_path rescue nil

    # attempt login with wrong password
    post session_path, params: {
      email_address: "wrongpasstest@example.com",
      password: "WrongPassword456!"
    }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal "Incorrect email or password!", flash[:inline_alert]
    user.destroy
  end

  # basis path 5: access all protected pages when logged in
  test "authenticated user can access protected pages" do
    user = User.create!(
      username: "protectedtest",
      email_address: "protectedtest@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    post session_path, params: {
      email_address: "protectedtest@example.com",
      password: "Password123!"
    }

    # access protected pages
    get trends_path
    assert_response :success, "Authenticated user should access trends page"

    get compare_path
    assert_response :success, "Authenticated user should access compare page"

    get bookmarks_path
    assert_response :success, "Authenticated user should access bookmarks page"

    user.destroy
  end

  # basis path 6: block access to protected pages for guests
  test "unauthenticated user cannot access protected pages" do
    # ensure logged out
    delete logout_path rescue nil

    # try to access protected pages
    get trends_path
    assert_redirected_to new_session_path, "Should redirect to login for trends"

    get compare_path
    assert_redirected_to new_session_path, "Should redirect to login for compare"

    get bookmarks_path
    assert_redirected_to new_session_path, "Should redirect to login for bookmarks"
  end

  # basis path 8: reset password with valid token
  test "password reset with valid token succeeds" do
    # Create user
    user = User.create!(
      username: "resettest",
      email_address: "resettest@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    # logout
    delete logout_path

    # submit password reset request
    post passwords_path, params: {
      email_address: "resettest@example.com"
    }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal "Password reset instructions sent! (if email address exists)", flash[:notice]

    # get password reset token
    user.reload
    password_reset_token = user.password_reset_token
    assert_not_nil password_reset_token, "Password reset token should be generated"

    # access password reset link with valid token
    get edit_password_path(token: password_reset_token)
    assert_response :success

    # successful password reset
    put password_path(token: password_reset_token), params: {
      password: "NewPassword123!",
      password_confirmation: "NewPassword123!"
    }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal "Password has been reset.", flash[:notice]

    # verify can login with new password
    post session_path, params: {
      email_address: "resettest@example.com",
      password: "NewPassword123!"
    }

    # should redirect after successful login
    assert_response :redirect
    follow_redirect!
    # after login with new password, should be able to access protected pages
    get bookmarks_path
    assert_response :success, "Should be able to access protected page after password reset and login"
    user.destroy
  end

  # basis path 9: password reset with invalid token
  test "password reset with invalid token fails" do
    # attempt to access password reset form with invalid token
    get edit_password_path(token: "invalid_token_fdsfdsfsfa")
    assert_redirected_to new_password_path
    follow_redirect!
    assert_equal "Password reset link is invalid or has expired! Please try submitting a password reset request again.", flash[:alert]
  end
end
