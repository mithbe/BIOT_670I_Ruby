require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one_user)
    sign_in @user
  end

  test "should get index" do
    get root_path
    assert_response :success
  end
end
