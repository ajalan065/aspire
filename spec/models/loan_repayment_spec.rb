require 'rails_helper'

RSpec.describe LoanRepayment, type: :model do
    describe "validations" do
        let!(:user) {
            create(:user)
        }

        let!(:loan) {
            create(:loan, user_id: user.id)
        }

        it "create loan_repayment obj with valid params" do
            installment = LoanRepayment.new(loan_id: loan.id, payment_date: Time.now, amount: 1000)
            expect(installment).to be_valid
        end

        it "should not create if amount is missing" do
            installment = LoanRepayment.new(loan_id: loan.id, payment_date: Time.now)
            expect(installment).not_to be_valid
        end

        it "should not create if payment_date is missing" do
            installment = LoanRepayment.new(loan_id: loan.id, amount: 1000)
            expect(installment).not_to be_valid
        end
    end

    describe "method verifications" do
        let!(:user) {
            create(:user)
        }

        let!(:loan) {
            create(:loan, user_id: user.id)
        }

        context "#mark_paid!" do
            it "should mark status as paid and set paid_at" do
                installment = LoanRepayment.find_by(loan_id: loan.id, status: :pending)
                installment.mark_paid!

                expect(installment.status).to eq("paid")
                expect(installment.paid_at).not_to be_nil
            end
        end
    end
end