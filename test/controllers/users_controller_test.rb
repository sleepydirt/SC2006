require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should create user with valid params" do
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          username: "newuser",
          email_address: "newuser@example.com",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    user = User.find_by(email_address: "newuser@example.com")
    assert_not_nil user

    user.destroy
  end

  test "should not create user with duplicate email" do
    # use the existing user created above
    existing_user = users(:one)

    # try to create another user with the same email, should now redirect with error
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          username: "newuser2",
          email_address: existing_user.email_address,
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_response :redirect
    assert_match /users\/new/, response.redirect_url
    follow_redirect!
    assert_equal "Email address is already registered!", flash[:inline_alert]
  end

  test "should not create user with mismatched password and confirmation" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          username: "test",
          email_address: "test@example.com",
          password: "Password123!",
          password_confirmation: "balsdjasdsadksadjkas"
        }
      }
    end

    assert_response :redirect
    assert_match /users\/new/, response.redirect_url
    follow_redirect!
    assert_equal "Passwords do not match!", flash[:inline_alert]
  end

  test "authenticated user is logged in after signup" do
    post users_path, params: {
      user: {
        username: "test",
        email_address: "test@example.com",
        password: "Password123!",
        password_confirmation: "Password123!"
      }
    }

    assert_redirected_to root_path
    user = User.find_by(email_address: "test@example.com")
    assert_not_nil user

    user.destroy if user
  end

  test "should not create user with password missing uppercase" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          username: "testuser",
          email_address: "test@example.com",
          password: "password123!",
          password_confirmation: "password123!"
        }
      }
    end

    assert_response :redirect
    assert_match /users\/new/, response.redirect_url
    follow_redirect!
    assert_equal "Password must contain at least 1 uppercase letter!", flash[:inline_alert]
  end

  test "should not create user with password missing number" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          username: "testuser",
          email_address: "test@example.com",
          password: "Password!",
          password_confirmation: "Password!"
        }
      }
    end

    assert_response :redirect
    assert_match /users\/new/, response.redirect_url
    follow_redirect!
    assert_equal "Password must contain at least 1 number!", flash[:inline_alert]
  end

  test "should not create user with password missing special character" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          username: "testuser",
          email_address: "test@example.com",
          password: "Password123",
          password_confirmation: "Password123"
        }
      }
    end

    assert_response :redirect
    assert_match /users\/new/, response.redirect_url
    follow_redirect!
    assert_equal "Password must contain at least 1 special character!", flash[:inline_alert]
  end

  test "should not create user with password too short" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          username: "testuser",
          email_address: "test@example.com",
          password: "Pass1!",
          password_confirmation: "Pass1!"
        }
      }
    end

    assert_response :redirect
    assert_match /users\/new/, response.redirect_url
    follow_redirect!
    assert_equal "Password must contain at least 8 characters!", flash[:inline_alert]
  end
end
