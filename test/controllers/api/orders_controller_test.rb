require "test_helper"

class Api::OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_orders_create_url
    assert_response :success
  end
end
