class LoanRepayment < ApplicationRecord
    belongs_to :loan

    enum status: { pending: 0, paid: 1 }

    validates_presence_of :amount, :payment_date
    validates_presence_of :paid_at, if: Proc.new { |obj| obj.status == :paid}

    def mark_paid!
        self.update(status: :paid, paid_at: Time.now)
    end
end
