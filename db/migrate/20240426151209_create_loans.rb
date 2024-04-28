class CreateLoans < ActiveRecord::Migration[6.0]
  def change
    create_table :loans do |t|
      t.integer :user_id
      t.integer :status, default: 0
      t.integer :term
      t.float :disbursed_amount
      t.float :collected_amount
      t.timestamp :start_date
      t.timestamps
    end

    add_index :loans, [:start_date, :term]
    add_index :loans, :user_id
  end
end
