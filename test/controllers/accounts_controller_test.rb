require "test_helper"

# Tests for the AccountsController
class AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Set up a logged-in user for the tests
  setup do
    @user = users(:one_user)
    sign_in @user
  end

  # Test that the account show page loads successfully
  test "should get show" do
    get account_path
    assert_response :success
  end

  # Test that the account edit page loads successfully
  test "should get edit" do
    get edit_account_path
    assert_response :success
  end

  # Test updating the user's email
  test "should update account" do
    patch account_path, params: { user: { email: "new_email@example.com" } }
    assert_redirected_to account_path
    @user.reload
    assert_equal "new_email@example.com", @user.email
  end
end
