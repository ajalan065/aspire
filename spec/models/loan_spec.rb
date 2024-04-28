require 'rails_helper'

RSpec.describe Loan, type: :model do
  describe "validations" do
    let!(:user) {
        create(:user)
    }

    it "is valid with valid attributes" do
      loan = Loan.new(disbursed_amount: 10000, term: 3, start_date: Time.now, user_id: user.id)
      expect(loan).to be_valid
    end

    it "is not valid without an amount" do
      loan = Loan.new(term: 3, start_date: Time.now, user_id: user.id)
      expect(loan).not_to be_valid
    end

    it "is not valid without term" do
        loan = Loan.new(disbursed_amount: 10000, start_date: Time.now, user_id: user.id)
        expect(loan).not_to be_valid
    end

    it "is not valid without start_date" do
        loan = Loan.new(term: 3, disbursed_amount: 10000, user_id: user.id)
        expect(loan).not_to be_valid
    end
  end

  describe "create_repayment_schedules" do
    let!(:user) {
        create(:user)
    }

    let!(:loan) {
      create(:loan, user_id: user.id)
    }

    it "should create multiple repayments for valid loan" do
        expect(LoanRepayment.where(loan_id: loan.id).size).to eq(loan.term)

        transaction = Transaction.find_by(associate_type: Loan.name, associate_id: LoanRepayment.first.loan_id)
        expect(transaction).not_to be_nil
    end
  end

  describe "reset_installment_amounts" do
    let!(:user) {
        create(:user)
    }
    let!(:loan) {
        create(:loan, user_id: user.id)
    }

    subject do 
        loan_installment = LoanRepayment.where(status: :pending, loan_id: loan.id).first
        loan_installment.mark_paid!

        loan.update(collected_amount: loan_installment.amount + 1000)
        loan.reset_installment_amounts
    end

    it "should recalculate and repopulate remaining loan amount for remaining terms" do
        subject

        remaining_installments = LoanRepayment.where(status: :pending, loan_id: loan.id)
        expect(remaining_installments.pluck(:amount).sum).to eq(loan.disbursed_amount-loan.collected_amount)
    end
  end
end
