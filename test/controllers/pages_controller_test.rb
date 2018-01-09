require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get pages_home_url
    assert_response :success
  end

  test "should get landing" do
    get pages_landing_url
    assert_response :success
  end

  test "should get test" do
    get pages_test_url
    assert_response :success
  end

end
