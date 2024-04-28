require 'rails_helper'

RSpec.describe Loans::LoanRepaymentsController, type: :controller do
    describe "#repay" do
        let!(:user) {
            create(:user)
        }

        let!(:user1) {
            create(:user, email: 'test@exaplme.com')
        }

        let!(:loan) {
            create(:loan, user_id: user.id)
        }

        context 'when user is not authenticated' do
            it "should return 302 to redirect user to sign in" do
                post :repay, params: {user_id: user.id, id: loan.id}

                expect(response.status).to eq(302)
            end
        end

        context 'when user is authenticated' do
            context 'when loan is not found' do
                before do
                    sign_in(user1)
                end

                it "should raise loan not found error" do
                    expect {
                        post :repay, params: {
                            user_id: user1.id,
                            id: loan.id
                        }
                    }.to raise_error(Errors::LoanNotFoundError)
                end
            end

            context 'when loan is found' do
                before do
                    sign_in(user)
                end

                context 'when loan is not approved or paid' do
                    before do 
                        loan.update(status: :paid)
                    end

                    it "should raise invalid loan and return" do
                        post :repay, params: {
                            user_id: user.id,
                            id: loan.id,
                            loan: {
                                amount: loan.loan_repayments.first.amount
                            }
                        }

                        expect(response.status).to eq(400)
                    end
                end

                context 'when loan is valid' do 
                    before do 
                        loan.update(status: :approved)
                    end

                    context 'when exact amount is passed' do
                        it 'should repay the installment' do
                            post :repay, params: {
                                user_id: user.id,
                                id: loan.id,
                                loan: {
                                    amount: loan.loan_repayments.first.amount
                                }
                            }

                            expect(response.status).to eq(200)

                            installment = loan.loan_repayments.first
                            expect(installment.status).to eq('paid')
                            
                            transaction = Transaction.find_by(associate_type: installment.class.name, associate_id: installment.id)
                            expect(transaction).not_to be_nil
                            expect(loan.reload.collected_amount).to eq(installment.amount)
                        end
                    end

                    context 'when more amount is passed' do
                        it 'should repay and reset the remaining installments' do
                            installment = loan.loan_repayments.first
                            last_installment = loan.loan_repayments.last
                            last_installment_amount = last_installment.amount

                            post :repay, params: {
                                user_id: user.id,
                                id: loan.id,
                                loan: {
                                    amount: loan.loan_repayments.first.amount + 1000
                                }
                            }

                            expect(response.status).to eq(200)
                            expect(installment.reload.status).to eq('paid')
                            
                            transaction = Transaction.find_by(associate_type: installment.class.name, associate_id: installment.id)
                            expect(transaction).not_to be_nil
                            expect(last_installment.reload.amount).not_to eq(last_installment_amount)
                        end
                    end

                    context 'when less amount is passed' do
                        it 'should return with error' do
                            post :repay, params: {
                                user_id: user.id,
                                id: loan.id,
                                loan: {
                                    amount: loan.loan_repayments.first.amount - 500
                                }
                            }

                            resp = JSON.parse(response.body)
                            expect(resp.with_indifferent_access.dig(:success)).to eq(false)
                        end
                    end
                end
            end
        end
    end
end