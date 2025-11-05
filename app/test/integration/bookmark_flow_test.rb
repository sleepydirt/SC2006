require "test_helper"

class BookmarkFlowTest < ActionDispatch::IntegrationTest
  setup do
    # Create test user for authenticated tests
    @user = User.create!(
      username: "bookmarkuser",
      email_address: "bookmark@example.com",
      password: "SecurePass123!",
      password_confirmation: "SecurePass123!"
    )

    # Create test courses
    @course1 = Course.create!(
      university: "National University of Singapore",
      school: "School of Computing",
      degree: "Computer Science"
    )

    @course2 = Course.create!(
      university: "Nanyang Technological University",
      school: "School of Computer Science and Engineering",
      degree: "Computer Engineering"
    )
  end

  teardown do
    Bookmark.where(user: @user).destroy_all
    @user.destroy if @user
    @course1.destroy if @course1
    @course2.destroy if @course2
  end

  # Basis path 1: unauthenticated user is redirected (authentication check fails)
  test "unauthenticated user cannot create bookmarks and is redirected to login" do
    delete logout_path rescue nil

    # Attempt to create a bookmark without authentication
    assert_no_difference("Bookmark.count") do
      post bookmarks_path, params: { course_id: @course1.id }
    end

    # Should be redirected to login page
    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal "You must be logged in to access this feature.", flash[:auth_required]
  end

  test "unauthenticated user cannot view bookmarks and is redirected to login" do
    delete logout_path rescue nil

    # Attempt to view bookmarks without authentication
    get bookmarks_path

    # Should be redirected to login page
    assert_redirected_to new_session_path
    follow_redirect!
    assert_equal "You must be logged in to access this feature.", flash[:auth_required]
  end

  # Basis path 2: Authenticated user + valid course + no existing bookmark, then create bookmark
  test "authenticated user can create a bookmark for a course" do
    # Login as test user
    post session_path, params: {
      email_address: @user.email_address,
      password: "SecurePass123!"
    }

    # Verify no bookmark exists initially
    assert_equal 0, Bookmark.where(user: @user, course: @course1).count

    # Create a bookmark
    assert_difference("Bookmark.count", 1) do
      post bookmarks_path, params: { course_id: @course1.id }
    end

    # Verify bookmark was created
    bookmark = Bookmark.find_by(user: @user, course: @course1)
    assert_not_nil bookmark, "Bookmark should be created"
    assert_equal @user.id, bookmark.user_id
    assert_equal @course1.id, bookmark.course_id
  end

  # Basis path 3: Authenticated user + valid course + existing bookmark, then remove bookmark (toggle)
  test "authenticated user can toggle bookmark to remove it" do
    # Login as test user
    post session_path, params: {
      email_address: @user.email_address,
      password: "SecurePass123!"
    }

    # Create an existing bookmark first
    existing_bookmark = Bookmark.create!(user: @user, course: @course1)
    assert_not_nil Bookmark.find_by(id: existing_bookmark.id), "Bookmark should exist before toggle"

    # Toggle the bookmark (should destroy it)
    assert_difference("Bookmark.count", -1) do
      post bookmarks_path, params: { course_id: @course1.id }
    end

    # Verify bookmark was removed
    assert_nil Bookmark.find_by(user: @user, course: @course1), "Bookmark should be removed after toggle"
  end

  # Basis path 4: Authenticated user + multiple operations + view bookmarks list
  test "authenticated user can manage multiple bookmarks and view them in list" do
    # Login as test user
    post session_path, params: {
      email_address: @user.email_address,
      password: "SecurePass123!"
    }
    assert_redirected_to root_path

    # Initially no bookmarks
    get bookmarks_path
    assert_response :success
    assert_equal 0, assigns(:courses).count, "Should have no bookmarks initially"

    # Add first bookmark
    assert_difference("Bookmark.count", 1) do
      post bookmarks_path, params: { course_id: @course1.id }
    end

    # Verify first bookmark appears in list
    get bookmarks_path
    assert_response :success
    courses = assigns(:courses)
    assert_equal 1, courses.count
    assert_includes courses.map(&:id), @course1.id

    # Add second bookmark
    assert_difference("Bookmark.count", 1) do
      post bookmarks_path, params: { course_id: @course2.id }
    end

    # Verify both bookmarks appear in list
    get bookmarks_path
    assert_response :success
    courses = assigns(:courses)
    assert_equal 2, courses.count
    assert_includes courses.map(&:id), @course1.id
    assert_includes courses.map(&:id), @course2.id

    # Remove first bookmark
    assert_difference("Bookmark.count", -1) do
      post bookmarks_path, params: { course_id: @course1.id }
    end

    # Verify only second bookmark remains
    get bookmarks_path
    assert_response :success
    courses = assigns(:courses)
    assert_equal 1, courses.count
    assert_includes courses.map(&:id), @course2.id
    assert_not_includes courses.map(&:id), @course1.id

    # Remove second bookmark
    assert_difference("Bookmark.count", -1) do
      post bookmarks_path, params: { course_id: @course2.id }
    end

    # Verify no bookmarks remain
    get bookmarks_path
    assert_response :success
    assert_equal 0, assigns(:courses).count, "Should have no bookmarks after removing all"
  end

  test "authenticated user cannot bookmark non-existent course" do
    # Login as test user
    post session_path, params: {
      email_address: @user.email_address,
      password: "SecurePass123!"
    }

    # Attempt to bookmark with invalid course_id
    assert_no_difference("Bookmark.count") do
      post bookmarks_path, params: { course_id: 99999 }
    end

    # Verify no bookmark was created for invalid course
    assert_nil Bookmark.find_by(course_id: 99999, user: @user)
  end

  test "bookmarks persist across user sessions" do
    # Login and create bookmarks
    post session_path, params: {
      email_address: @user.email_address,
      password: "SecurePass123!"
    }

    post bookmarks_path, params: { course_id: @course1.id }
    post bookmarks_path, params: { course_id: @course2.id }

    # Verify bookmarks exist
    assert_equal 2, Bookmark.where(user: @user).count

    # Logout
    delete logout_path
    assert_redirected_to root_path

    # Login again
    post session_path, params: {
      email_address: @user.email_address,
      password: "SecurePass123!"
    }

    # Verify bookmarks still exist
    get bookmarks_path
    assert_response :success
    courses = assigns(:courses)
    assert_equal 2, courses.count, "Bookmarks should persist across sessions"
  end
end
