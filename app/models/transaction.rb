class Transaction < ApplicationRecord
    enum status: {pending: 0, completed: 1, failed: 2}
    enum transaction_type: {credit: 0, debit: 1}
end
