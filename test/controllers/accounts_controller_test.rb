require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one_user)
    sign_in @user
  end

  test "should get show" do
    get account_path
    assert_response :success
  end

  test "should get edit" do
    get edit_account_path
    assert_response :success
  end

  test "should update account" do
    patch account_path, params: { user: { email: "new_email@example.com" } }
    assert_redirected_to account_path
    @user.reload
    assert_equal "new_email@example.com", @user.email
  end
end
