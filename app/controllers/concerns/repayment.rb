module Repayment
    extend ActiveSupport::Concern

    def repay_installment(loan_id, amount)
        loan = Loan.find_by(id: loan_id)

        pending_installment = LoanRepayment.where(
            loan_id: loan_id,
            status: :pending
        ).order('payment_date asc').first

        return unless pending_installment.present?

        return {status: :invalid_amount, success: false} if amount < pending_installment.amount

        excess = amount - pending_installment.amount
        
        ActiveRecord::Base.transaction do
            Transaction.create!(
                associate_type: pending_installment.class.name,
                associate_id: pending_installment.id,
                payment_date: Time.now,
                amount: pending_installment.amount,
                transaction_type: :credit,
                status: :completed,
                excess_balance: excess
            )

            pending_installment.mark_paid!
        end
        
        # update the loan amount if user paid extra and reset installment amount
        collected_amt = loan.collected_amount.to_f
        loan.update!(collected_amount: collected_amt + amount)

        loan.reset_installment_amounts if excess

        return {success: true}
    end
end