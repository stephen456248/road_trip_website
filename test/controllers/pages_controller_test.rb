require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get weather" do
    get :weather
    assert_response :success
  end

  test "should get roads" do
    get :roads
    assert_response :success
  end

  test "should get cams" do
    get :cams
    assert_response :success
  end

end
