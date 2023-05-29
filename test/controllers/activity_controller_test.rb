require "test_helper"

class ActivityControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get activity_index_url
    assert_response :success
  end

  test "should get show" do
    get activity_show_url
    assert_response :success
  end
end
