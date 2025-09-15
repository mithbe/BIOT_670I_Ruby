require "test_helper"

class SamplesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one_user)
    sign_in @user
    @sample = samples(:sample_one)
  end

  test "should get index" do
    get samples_path
    assert_response :success
  end

  test "should get show" do
    get sample_path(@sample)
    assert_response :success
  end

  test "should get new" do
    get new_sample_path
    assert_response :success
  end

  test "should get edit" do
    get edit_sample_path(@sample)
    assert_response :success
  end
end
