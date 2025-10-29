require "test_helper"

# Tests for the Admin::MetadataController
class Admin::MetadataControllerTest < ActionDispatch::IntegrationTest
  # Test that the index page loads successfully
  test "should get index" do
    get admin_metadata_index_url
    assert_response :success
  end

  # Test that the show page loads successfully
  test "should get show" do
    get admin_metadata_show_url
    assert_response :success
  end

  # Test that the edit page loads successfully
  test "should get edit" do
    get admin_metadata_edit_url
    assert_response :success
  end

  # Test that the update page works successfully
  test "should get update" do
    get admin_metadata_update_url
    assert_response :success
  end
end
