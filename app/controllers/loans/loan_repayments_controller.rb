class Loans::LoanRepaymentsController < ApplicationController

  include ::Errors
  include Repayment

  before_action :authenticate_user!
  before_action :set_loan, only: %i[ repay ]
 
  # POST /loan/{id}/repay
  def repay
    amount = permitted_params.dig(:loan).dig(:amount).to_f

    loan_status = @loan.status.to_sym

    case loan_status
    when :pending
      render json: {msg: 'Loan is pending'}, status: 400 and return
    when :paid
      render json: {msg: 'Loan is already paid'}, status: 400 and return
    else
      resp = repay_installment(@loan.id, amount)
    end

    if resp.with_indifferent_access.dig(:success)
      render json: {success: true, msg: 'Loan Installment paid successfully'}, status: :ok
    else
      render json: {success: false, status: resp.with_indifferent_access.dig(:status)}, status: :ok
    end
  end

  private

  def set_loan
    @loan = Loan.find_by(id: params.dig(:id), user_id: current_user.id)

    raise LoanNotFoundError unless @loan.present?
  end

  def permitted_params
    params.permit!
  end
end
