Rails.application.routes.draw do
  devise_for :users #, controllers: {registrations: 'users/registrations', sessions: 'users/sessions'}
  
  resources :users do
    resources :loans do
      member do 
        post :approve
        post '/repay', to: 'loans/loan_repayments#repay'
      end

      resources :loan_repayments
    end
  end
end
