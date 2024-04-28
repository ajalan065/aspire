require 'rails_helper'

RSpec.describe LoansController, type: :controller do
    describe "#index" do
        let!(:user) {
            create :user
        }
        let!(:loan) {
            create(:loan, user_id: user.id)
        }

        context "when user is authenticated" do
            before do 
                sign_in(user)
            end

            it "should show loans of the user" do
                get :index, params: {user_id: user.id}

                expect(response.status).to eq(200)
                loans = JSON.parse(response.body)

                expect(loans.size).not_to eq(0)
                expect(loans.first.with_indifferent_access.dig(:id)).to eq(loan.id)
            end
        end

        context "when user is not authenticated" do
            it "should return 302 to redirect user to sign in" do
                get :index, params: {user_id: user.id}

                expect(response.status).to eq(302)
            end
        end
    end

    describe "#create" do
        let!(:user) {
            create(:user)
        }

        let!(:loan) {
            create(:loan, user_id: user.id)
        }

        context "when user is not authenticated" do
            it "should return 302 to redirect user to sign in" do
                post :create, params: {
                    user_id: user.id,
                    loan: {
                        term: 3,
                        disbursed_amount: 10000,
                        start_date: Time.now
                    }
                }

                expect(response.status).to eq(302)
            end
        end
        
        context "when user is authenticated" do
            before do
                sign_in(user)
            end

            it "should create loan in pending state when params are valid" do
                post :create, params: {
                    user_id: user.id,
                    loan: {
                        term: 3,
                        disbursed_amount: 20000,
                        start_date: Time.now
                    }
                }
                
                expect(response.status).to eq(200)
                resp = JSON.parse(response.body)

                expect(resp.with_indifferent_access.dig(:user_id)).to eq(user.id)
            end

            it "should not create loan with invalid params and return 422" do
                post :create, params: {
                    user_id: user.id,
                    loan: {
                        term: 3,
                        start_date: Time.now
                    }
                }

                expect(response.status).to eq(422)
                resp = JSON.parse(response.body)
                expect(resp.with_indifferent_access.dig(:error)).not_to be_nil
            end
        end
    end

    describe "#approve" do
        let!(:user) {
            create(:user)
        }

        let!(:admin) {
            create(:user, email: 'admin1@example.com')
        }

        let!(:loan) {
            create(:loan, user_id: user.id)
        }

        context "when user is not authenticated" do
            it "should return 302 to redirect user to sign in" do
                post :approve, params: {user_id: user.id, id: loan.id}

                expect(response.status).to eq(302)
            end
        end

        context "when user is authenticated" do
            context "when user is admin" do
                before do
                    admin.add_role(:admin)
                    sign_in(admin) 
                end

                it "should be able to approve" do
                    expect(loan.status).to eq('pending')

                    post :approve, params: {user_id: user.id, id: loan.id}
                    loan.reload
                    expect(loan.status).to eq('approved')
                end
            end

            context "when user is not admin" do
                before do
                    sign_in(user)
                end

                it "should raise Invalid Access error" do
                    expect{
                        post :approve, params: {user_id: user.id, id: loan.id}
                    }.to raise_error(Errors::InvalidAccessError)
                end
            end
        end
    end

    describe "#show" do
        let!(:user) {
            create :user
        }

        let!(:user2) {
            create(:user, email: "test2@example.com")
        }

        let!(:loan) {
            create(:loan, user_id: user.id)
        }

        context "when user is not authenticated" do
            it "should return 302 to redirect user to sign in" do
                get :show, params: {user_id: user.id, id: loan.id}

                expect(response.status).to eq(302)
            end
        end

        context "when user is authenticated" do
            context "when user is a customer" do
                context "trying to access his own loans" do
                    before do 
                        sign_in(user)
                    end

                    it "should be able to access" do
                        get :show, params: {user_id: user.id, id: loan.id}

                        expect(response.status).to eq(200)
                        resp = JSON.parse(response.body).with_indifferent_access

                        expect(resp.dig(:id)).to eq(loan.id)
                    end
                end

                context "trying to access other's loans" do
                    before do
                        sign_in(user2) 
                    end

                    it "should not be able to access" do
                        expect {
                            get :show, params: {user_id: user2.id, id: loan.id}
                        }.to raise_error(ActionPolicy::Unauthorized)
                    end
                end
            end

            context "when user is admin" do
                let!(:admin) {
                    create(:user, email: 'admin1@example.com')
                }

                before do
                    admin.add_role(:admin)
                    sign_in(admin)
                end

                context "trying to access any loan" do
                    it "should be able to access" do
                        get :show, params: {user_id: admin.id, id: loan.id}
                        expect(response.status).to eq(200)
                    end
                end
            end
        end
    end
end