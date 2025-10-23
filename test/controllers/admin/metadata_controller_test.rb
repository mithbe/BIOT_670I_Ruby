require "test_helper"

class Admin::MetadataControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_metadata_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_metadata_show_url
    assert_response :success
  end

  test "should get edit" do
    get admin_metadata_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_metadata_update_url
    assert_response :success
  end
end
