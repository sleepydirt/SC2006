require "test_helper"

class UserTest < ActiveSupport::TestCase
  # testing boundary values on the model side
  # controller already tests, this is just mostly repeating the same tests

  test "password with exactly 7 characters should be invalid" do
    user = User.new(
      username: "testuser",
      email_address: "test@example.com",
      password: "Pass1!a",  # 7 chars
      password_confirmation: "Pass1!a"
    )

    assert_not user.valid?
    assert_includes user.errors[:base], "Password must contain at least 8 characters!"
  end

  test "password with exactly 8 characters should be valid" do
    user = User.new(
      username: "testuser",
      email_address: "boundary8@example.com",
      password: "Pass123!",  # 8 chars
      password_confirmation: "Pass123!"
    )

    assert user.valid?, "User with 8-character password should be valid: #{user.errors.full_messages}"
  end

  test "password with exactly 9 characters should be valid" do
    user = User.new(
      username: "testuser",
      email_address: "boundary9@example.com",
      password: "Pass1234!",  # 9 chars
      password_confirmation: "Pass1234!"
    )

    assert user.valid?, "User with 9-character password should be valid: #{user.errors.full_messages}"
  end

  # testing password complexity requirements
  test "password with 0 uppercase letters should be invalid" do
    user = User.new(
      username: "testuser",
      email_address: "test@example.com",
      password: "password123!",
      password_confirmation: "password123!"
    )

    assert_not user.valid?
    assert_includes user.errors[:base], "Password must contain at least 1 uppercase letter!"
  end

  test "password with exactly 1 uppercase letter should be valid" do
    user = User.new(
      username: "testuser",
      email_address: "uppercase1@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    assert user.valid?, "Password with 1 uppercase should be valid: #{user.errors.full_messages}"
  end

  test "password with 0 numbers should be invalid" do
    user = User.new(
      username: "testuser",
      email_address: "test@example.com",
      password: "Password!",
      password_confirmation: "Password!"
    )

    assert_not user.valid?
    assert_includes user.errors[:base], "Password must contain at least 1 number!"
  end

  test "password with exactly 1 number should be valid" do
    user = User.new(
      username: "testuser",
      email_address: "number1@example.com",
      password: "Password1!",
      password_confirmation: "Password1!"
    )

    assert user.valid?, "Password with 1 number should be valid: #{user.errors.full_messages}"
  end

  test "password with 0 special characters should be invalid" do
    user = User.new(
      username: "testuser",
      email_address: "test@example.com",
      password: "Password123",
      password_confirmation: "Password123"
    )

    assert_not user.valid?
    assert_includes user.errors[:base], "Password must contain at least 1 special character!"
  end

  test "password with exactly 1 special character should be valid" do
    user = User.new(
      username: "testuser",
      email_address: "special1@example.com",
      password: "Password1!",
      password_confirmation: "Password1!"
    )

    assert user.valid?, "Password with 1 special character should be valid: #{user.errors.full_messages}"
  end

  # boundary tests for all the user's personal information (year of study)
  test "year_of_study with 0 should be invalid" do
    user = User.create!(
      username: "testuser",
      email_address: "year0@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    user.year_of_study = 0
    assert_not user.valid?
    assert_includes user.errors[:year_of_study], "must be greater than 0"
  end

  test "year_of_study with 1 should be valid" do
    user = User.create!(
      username: "testuser",
      email_address: "year1@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    user.year_of_study = 1
    assert user.valid?, "Year 1 should be valid: #{user.errors.full_messages}"
  end

  test "year_of_study with 6 should be valid" do
    user = User.create!(
      username: "testuser",
      email_address: "year6@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    user.year_of_study = 6
    assert user.valid?, "Year 6 should be valid: #{user.errors.full_messages}"
  end

  test "year_of_study with 7 should be invalid (above maximum)" do
    user = User.create!(
      username: "testuser",
      email_address: "year7@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    user.year_of_study = 7
    assert_not user.valid?
    assert_includes user.errors[:year_of_study], "must be less than or equal to 6"
  end

  # equivalence tests for other user profile fields
  test "empty course string should become nil" do
    user = User.create!(
      username: "testuser",
      email_address: "emptycourse@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    user.course = ""
    user.valid?
    assert_nil user.course, "Empty course should become nil"
  end

  test "valid course should be accepted" do
    user = User.create!(
      username: "testuser",
      email_address: "validcourse@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    user.course = "Computer Science"
    assert user.valid?, "Valid course should be accepted: #{user.errors.full_messages}"
  end

  test "empty institution string should become nil" do
    user = User.create!(
      username: "testuser",
      email_address: "emptyinst@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    user.institution = ""
    user.valid?
    assert_nil user.institution, "Empty institution should become nil"
  end

  test "valid institution should be accepted" do
    user = User.create!(
      username: "testuser",
      email_address: "validinst@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    user.institution = "NTU"
    assert user.valid?, "Valid institution should be accepted: #{user.errors.full_messages}"
  end

  test "non-integer year_of_study should be invalid" do
    user = User.create!(
      username: "testuser",
      email_address: "nonyear@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    user.year_of_study = 2.5
    assert_not user.valid?
    assert_includes user.errors[:year_of_study], "must be an integer"
  end
end
