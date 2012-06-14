require 'test_helper'

class SearchTracksControllerTest < ActionController::TestCase
  test "should get search" do
    get :search
    assert_response :success
  end

  test "should get list" do
    get :list
    assert_response :success
  end

end
