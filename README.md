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

Test via Rspecs
--------------
### Cases covered

Models:
<ol>
<li><strong>Loan</strong></li>
    a. Validations check -- <br>
        i. Invalid if term / amount / start date is missing<br>
        ii. Creates loans if all the above are present<br>
    b. Repayment schedule creation --<br>
        i. Creates multiple installments for valid loans<br>
    c. Reset installment amount in case of excess payments --<br>
        i. Adjusted in all remaining pending installments<br>
<li><strong>LoanRepayment</strong></li>
    a. Validations check --<br>
        i. Invalid if amount / payment date is missing<br>
        ii. Create repayments if all the above are present<br>
    b. Installments marked paid --<br>
        i. Immediate next pending installment is marked paid.<br>
            - If amount is equal, then just update status<br>
            - If amount is less, then raise error and return without doing anything<br>
            - If amount is greater, then adjust the excess balance among remaining pending installments.<br>
<li><strong>User</strong></li>
    a. Assign default role to user --<br>
        i. On user creation, give default role as `customer`.<br>
</ol>

Controllers:<br>
<ol>
<li><strong>LoansController</strong></li>
    a. #index action --<br>
        i. When user is not authenticated, return 302 (should be redirecting to signin page from UI perspective)<br>
        ii. When user is authenticated<br>
            - Should show loans of the user<br>
    b. #create action --<br>
        i. When user is not authenticated, return 302<br>
        ii. When user is authenticated<br>
            - If invalid params, then do not create object and return 422<br>
            - If valid params, then create loan in `pending` state<br>
    c. #approve action --<br>
        i. When user is not authenticated, return 302<br>
        ii. When user is authenticated<br>
            - When user is admin, should be able to approve loans<br>
            - When user is not admin, should not be able to approve loans<br>
    d. #show action --<br>
        i. When user is not authenticated, return 302<br>
        ii. When user is authenticated<br>
            - When user is admin, can access any loan<br>
            - When user is customer, should be able to access only his own loans<br>
<li><strong>LoanRepaymentsController</strong></li>
    a. #repay action --<br>
        i. When user is not authenticated, return 302<br>
        ii. When user is authenticated<br>
            - Raise Loan Not Found error if no loan found for passed id.<br>
            - Raise invalid loan error if loan is not approved or already paid<br>
            - When loan is valid<br>
                -> If amount is equal, mark the installment paid<br>
                -> If amount is less, do not update the status and return with error message<br>
                -> If amount is greater, mark the installment paid and adjust the excess balance in next all pending installments equally.<br>

### How to Run Rspecs

1. For models, run in terminal `rspec spec/models`
2. For controllers, run in terminal `rspec spec/controllers`

Test via API
------------

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

The above two ids will be handy in calling APIs from postman.<br>

<ol>
<li><strong>Authenticating user:</strong></li>
    a. Endpoint: `POST http://localhost:3000/users/sign_in`<br>
    b. To login as customer, use the below credentials in body param:
    <pre>
    {
        "user": {
            "email": "customer@example.com",
            "password": "password"
        }
    }
    </pre>
    <br>
    c. To login as admin, user the below credentials:
    <pre>
    {
        "user": {
            "email": "admin@example.com",
            "password": "password"
        }
    }
    </pre>
<br>
<li><strong>To create loan:</strong></li>
    a. Endpoint: `POST http://localhost:3000/users/{customer_id}/loans`<br>
    b. Body:
    <pre>
    {
        "loan": {
            "disbursed_amount": 5000,
            "term": 2,
            "start_date": "2024-04-29"
        }
    }
    </pre>
    <br>
    c. This will return an object in JSON format. Please note the loan id under the attribute `id`. This will be used in endpoints to approve / repay installments.
<li><strong>To approve loan:</strong></li>
    a. Logout from existing session using the below (in case logged in as customer). Endpoint `DELETE http://localhost:3000/users/sign_out`<br>
    b. Login using admin as shown in Step 1(c).<br>
    c. For approving loan - Endpoint: `POST http://localhost:3000/users/{customer_id}/loans/{id}/approve`
<li><strong>To repay the installment:</strong></li>
    a. Log in as customer using first step of Approve Loan (in case logged in as admin). Endpoint: `POST http://localhost:3000/users/{customer_id}/loans/{id}/repay`<br>
    b. Body:
        <pre>
        {
            "loan": {
                "amount": 1000
            }
        }
        </pre>
        <br>
    c. Marks the installment as paid.