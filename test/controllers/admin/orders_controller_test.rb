require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_orders_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_orders_show_url
    assert_response :success
  end

  test "should get new" do
    get admin_orders_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_orders_edit_url
    assert_response :success
  end
end
