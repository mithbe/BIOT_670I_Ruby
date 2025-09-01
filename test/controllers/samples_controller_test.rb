require "test_helper"

class SamplesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get samples_index_url
    assert_response :success
  end

  test "should get show" do
    get samples_show_url
    assert_response :success
  end

  test "should get new" do
    get samples_new_url
    assert_response :success
  end

  test "should get edit" do
    get samples_edit_url
    assert_response :success
  end
end
