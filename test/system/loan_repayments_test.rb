require "application_system_test_case"

class LoanRepaymentsTest < ApplicationSystemTestCase
  setup do
    @loan_repayment = loan_repayments(:one)
  end

  test "visiting the index" do
    visit loan_repayments_url
    assert_selector "h1", text: "Loan Repayments"
  end

  test "creating a Loan repayment" do
    visit loan_repayments_url
    click_on "New Loan Repayment"

    click_on "Create Loan repayment"

    assert_text "Loan repayment was successfully created"
    click_on "Back"
  end

  test "updating a Loan repayment" do
    visit loan_repayments_url
    click_on "Edit", match: :first

    click_on "Update Loan repayment"

    assert_text "Loan repayment was successfully updated"
    click_on "Back"
  end

  test "destroying a Loan repayment" do
    visit loan_repayments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Loan repayment was successfully destroyed"
  end
end
