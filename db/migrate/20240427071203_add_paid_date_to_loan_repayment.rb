class AddPaidDateToLoanRepayment < ActiveRecord::Migration[6.0]
  def change
    add_column :loan_repayments, :paid_at, :timestamp
    add_index :loan_repayments, :paid_at
  end
end
