class CreateTransaction < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.string :associate_type
      t.integer :associate_id
      t.timestamp :payment_date
      t.float :amount
      t.float :excess_balance
      t.integer :transaction_type
      t.integer :status
      t.timestamps

      t.index [:associate_type, :associate_id]
      t.index [:status, :transaction_type]
    end
  end
end
