require 'test_helper'

class CompanyInvitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company_invit = company_invits(:one)
  end

  test "should get index" do
    get company_invits_url
    assert_response :success
  end

  test "should get new" do
    get new_company_invit_url
    assert_response :success
  end

  test "should create company_invit" do
    assert_difference('CompanyInvit.count') do
      post company_invits_url, params: { company_invit: { company_id: @company_invit.company_id, email: @company_invit.email } }
    end

    assert_redirected_to company_invit_url(CompanyInvit.last)
  end

  test "should show company_invit" do
    get company_invit_url(@company_invit)
    assert_response :success
  end

  test "should get edit" do
    get edit_company_invit_url(@company_invit)
    assert_response :success
  end

  test "should update company_invit" do
    patch company_invit_url(@company_invit), params: { company_invit: { company_id: @company_invit.company_id, email: @company_invit.email } }
    assert_redirected_to company_invit_url(@company_invit)
  end

  test "should destroy company_invit" do
    assert_difference('CompanyInvit.count', -1) do
      delete company_invit_url(@company_invit)
    end

    assert_redirected_to company_invits_url
  end
end
