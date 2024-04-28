class LoansController < ApplicationController
  include ::Errors

  before_action :authenticate_user!
  before_action :set_loan, only: %i[ show edit approve ]
  before_action :check_admin_access, only: %i[ approve ]

  # GET /loans or /loans.json
  def index
    @loans = current_user.loans

    render json: @loans, status: :ok
  end

  # GET /loans/1 or /loans/1.json
  def show
    authorize! @loan
    render json: @loan, status: :ok
  end

  # POST /loans or /loans.json
  def create
    params[:status] = :pending
    
    @loan = Loan.new(loan_params)
    @loan.user_id = current_user.id

    if @loan.save
      render json: @loan, status: :ok
    else
      render json: {error: @loan.errors}, status: :unprocessable_entity
    end
  end

  def approve
    @loan.update(status: :approved)

    render json: {msg: 'Loan approved'}, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_loan
      @loan = Loan.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def loan_params
      params.require(:loan).permit!
    end

    def check_admin_access
      unless current_user.present? && current_user.has_role?(:admin)
        raise InvalidAccessError.new
      end
    end
end
