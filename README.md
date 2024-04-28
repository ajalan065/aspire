# README

This README covers setting up of the application and how to test it out.

Things you may want to cover:

* Ruby version - 2.5.1

* Rails version - 6+

#### Assumptions:
1. The application does not cover the scope of creation of customers or admins, and hence, dummy accounts are already created for testing purposes.
2. If the customer pays extra in any installment, then the excess balance is adjusted equally among all the next upcoming installments.
3. Loan repayment will always be done for immediate next pending installment, and can not be skipped under any case.
4. Loan repayments are always done on the pre-populated payment date in database.

### Steps to set up the application:

1. Download the repo from https://github.com/ajalan065/aspire.git
2. Install the gems - `bundle install`
3. Set up database - `rake db:setup && rake db:migrate && rake db:seed`
4. Application is set to use.

## Test via Rspecs

Cases covered:
--------------

Models:<br>
1. <strong>Loan</strong>
    a. Validations check -- 
        i. Invalid if term / amount / start date is missing
        ii. Creates loans if all the above are present
    b. Repayment schedule creation --
        i. Creates multiple installments for valid loans
    c. Reset installment amount in case of excess payments --
        i. Adjusted in all remaining pending installments
2. <strong>LoanRepayment</strong>
    a. Validations check --
        i. Invalid if amount / payment date is missing
        ii. Create repayments if all the above are present
    b. Installments marked paid --
        i. Immediate next pending installment is marked paid.
            - If amount is equal, then just update status
            - If amount is less, then raise error and return without doing anything
            - If amount is greater, then adjust the excess balance among remaining pending installments.
3. <strong>User</strong>
    a. Assign default role to user --
        i. On user creation, give default role as `customer`.

Controllers:<br>
1. <strong>LoansController</strong>
    a. #index action --
        i. When user is not authenticated, return 302 (should be redirecting to signin page from UI perspective)
        ii. When user is authenticated
            - Should show loans of the user
    b. #create action --
        i. When user is not authenticated, return 302
        ii. When user is authenticated
            - If invalid params, then do not create object and return 422
            - If valid params, then create loan in `pending` state
    c. #approve action --
        i. When user is not authenticated, return 302
        ii. When user is authenticated
            - When user is admin, should be able to approve loans
            - When user is not admin, should not be able to approve loans
    d. #show action --
        i. When user is not authenticated, return 302
        ii. When user is authenticated
            - When user is admin, can access any loan
            - When user is customer, should be able to access only his own loans
2. <strong>LoanRepaymentsController</strong>
    a. #repay action --
        i. When user is not authenticated, return 302
        ii. When user is authenticated
            - Raise Loan Not Found error if no loan found for passed id.
            - Raise invalid loan error if loan is not approved or already paid
            - When loan is valid
                -> If amount is equal, mark the installment paid
                -> If amount is less, do not update the status and return with error message
                -> If amount is greater, mark the installment paid and adjust the excess balance in next all pending installments equally,

How to Run Rspecs
-----------------
1. For models, run in terminal `rspec spec/models`
2. For controllers, run in terminal `rspec spec/controllers`

* Test via API
1. The application is seeded up with two users:
    a. Customer - Email: `customer@example.com` -- Password: `password`
    b. Admin - Email: `admin@example.com` -- Password: `password`
2. The application uses devise for authentication.

How to test
-----------
Run `rails s` to start the rails server at port 3000

Note: Open Rails console using `rails c` and type the below code snippets:
```
customer_id = User.find_by(email: 'customer@example.com').id
admin_id = User.find_by(email: 'admin@example.com').id
```

The above two ids will be handy in calling APIs from postman

1. Authenticating user:
    a. Endpoint: `POST http://localhost:3000/users/sign_in`
    b. To login as customer, use the below credentials in body param:
```
{
    "user": {
        "email": "customer@example.com",
        "password": "password"
    }
}
```
    c. To login as admin, user the below credentials:
```
{
    "user": {
        "email": "admin@example.com",
        "password": "password"
    }
}
```
2. To create loan:
    a. Endpoint: `POST http://localhost:3000/users/{customer_id}/loans`
    b. Body:
        ```
        {
            "loan": {
                "disbursed_amount": 5000,
                "term": 2,
                "start_date": "2024-04-29"
            }
        }
        ```
    c. This will return an object in JSON format. Please note the loan id under the attribute `id`. This will be used in endpoints to approve / repay installments.
3. To approve loan:
    a. Logout from existing session using the below. Endpoint `DELETE http://localhost:3000/users/sign_out`
    b. Login using admin as shown in Step 1(c).
    c. For approving loan:
        - Endpoint: `POST http://localhost:3000/users/{customer_id}/loans/{id}/approve`
4. To repay the installment:
    a. Endpoint: `POST http://localhost:3000/users/{customer_id}/loans/{id}/repay`
    b. Body:
        ```
        {
            "loan": {
                "amount": 1000
            }
        }
        ```
    c. Marks the installment as paid.