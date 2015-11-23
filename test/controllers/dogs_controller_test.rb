require 'test_helper'

class DogsControllerTest < ActionController::TestCase
  test "should get feed" do
    get :feed
    assert_response :success
  end

  test "should get walk" do
    get :walk
    assert_response :success
  end

  test "should get call" do
    get :call
    assert_response :success
  end

end
