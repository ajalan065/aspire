class CreateLoanRepayments < ActiveRecord::Migration[6.0]
  def change
    create_table :loan_repayments do |t|
      t.integer :loan_id
      t.integer :status
      t.float :amount
      t.timestamp :payment_date
      t.timestamps
    end

    add_index :loan_repayments, :loan_id
    add_index :loan_repayments, [:payment_date, :status]
  end
end
