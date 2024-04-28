require 'test_helper'

class LoanRepaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @loan_repayment = loan_repayments(:one)
  end

  test "should get index" do
    get loan_repayments_url
    assert_response :success
  end

  test "should get new" do
    get new_loan_repayment_url
    assert_response :success
  end

  test "should create loan_repayment" do
    assert_difference('LoanRepayment.count') do
      post loan_repayments_url, params: { loan_repayment: {  } }
    end

    assert_redirected_to loan_repayment_url(LoanRepayment.last)
  end

  test "should show loan_repayment" do
    get loan_repayment_url(@loan_repayment)
    assert_response :success
  end

  test "should get edit" do
    get edit_loan_repayment_url(@loan_repayment)
    assert_response :success
  end

  test "should update loan_repayment" do
    patch loan_repayment_url(@loan_repayment), params: { loan_repayment: {  } }
    assert_redirected_to loan_repayment_url(@loan_repayment)
  end

  test "should destroy loan_repayment" do
    assert_difference('LoanRepayment.count', -1) do
      delete loan_repayment_url(@loan_repayment)
    end

    assert_redirected_to loan_repayments_url
  end
end
