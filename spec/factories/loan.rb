FactoryBot.define do
    factory :loan do
        disbursed_amount {10000}
        term {3}
        start_date {Time.now}
        user_id {1}
    end
end