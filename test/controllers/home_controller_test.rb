require "test_helper"

# Tests for the HomeController
class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Log in a user before each test
  setup do
    @user = users(:one_user)
    sign_in @user
  end

  # Test that the home page loads successfully
  test "should get index" do
    get root_path
    assert_response :success
  end
end
