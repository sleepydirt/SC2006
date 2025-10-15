require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should create user with valid params" do
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          username: "newuser",
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
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

    # try to create another user with the same email, should fail
    assert_raises(ActiveRecord::RecordNotUnique) do
      post users_path, params: {
        user: {
          username: "newuser2",
          email_address: existing_user.email_address,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
  end

  test "should not create user with mismatched password and confirmation" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          username: "test",
          email_address: "test@example.com",
          password: "password123",
          password_confirmation: "balsdjasdsadksadjkas"
        }
      }
    end
  end

  test "authenticated user is logged in after signup" do
    post users_path, params: {
      user: {
        username: "test",
        email_address: "test@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_redirected_to root_path
    user = User.find_by(email_address: "test@example.com")
    assert_not_nil user

    user.destroy if user
  end
end
