class Loan < ApplicationRecord
    belongs_to :user
    has_many :loan_repayments

    enum status: { pending: 0, approved: 1, paid: 2 }

    after_create :record_transaction
    after_create :create_repayment_schedules

    after_commit :check_and_update_status

    validates_presence_of :term, :disbursed_amount, :start_date

    def create_repayment_schedules
        emi_amt = (disbursed_amount / term).round(2)
        rem_balance = disbursed_amount - (emi_amt * term)
        repayments = []

        0.upto(term-1).each do |t|
            emi_amt += rem_balance if t == term-1
            payment_date = self.start_date + ((t+1)*7).days

            repayments << LoanRepayment.new(
                loan_id: self.id,
                status: :pending,
                amount: emi_amt,
                payment_date: payment_date
            )
        end

        LoanRepayment.import repayments
    end

    def record_transaction
        Transaction.create!(
            associate_type: self.class.name,
            associate_id: self.id,
            payment_date: Time.now,
            amount: self.disbursed_amount,
            transaction_type: :debit,
            status: :completed
        )
    end

    def reset_installment_amounts
        pending_installments = LoanRepayment.where(loan_id: self.id, status: :pending)
        balance_amount = self.disbursed_amount - self.collected_amount

        if pending_installments.present? && (balance_amount>0)
            emi_amt = (balance_amount/pending_installments.size).round(2)
            rounded_off_margin = balance_amount - (emi_amt * pending_installments.size)

            0.upto(pending_installments.size-1).each do |i|
                emi_amt += rounded_off_margin if i == pending_installments.size-1

                repayment = pending_installments[i]
                repayment.update(amount: emi_amt)
            end
        end
    end

    def check_and_update_status
        installments = self.loan_repayments.pluck(:status).uniq!
        if (status == 'approved') && ((collected_amount == disbursed_amount) || (!installments.include?('pending')))
            self.loan_repayments.update_all(status: :paid)
            self.update!(status: :paid)
        end
    end
end
