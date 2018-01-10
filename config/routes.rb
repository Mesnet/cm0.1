Rails.application.routes.draw do
 
  resources :company_invits
  resources :invitation_companies
   # USERS
  devise_for :users
  resources :user_infos
  devise_scope :user do
    get 'user_info_register' => 'devise/registrations#user_info_register', :as => 'user_info_register'
    get "log_out" => "devise/sessions#destroy", :as => "log_out"
    get "login" => "devise/sessions#new", :as => "login"
    post "login" => "devise/sessions#create", :as => "log_in"
    get "sign_up" => "users#new", :as => "sign_up"
  end 
  # Admin interface
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  
  # COMPANY
  resources :companies do 
    member do
      patch :acc_invit
      patch :den_invit
      patch :create_invit
      patch :del_invit
      patch :quit
      patch :expel
      patch :show_users
      patch :upd_role
    end
  end

  get "company_invit" => "companies#company_invit"
  get "company_manage" => "companies#new"
  patch "info_step" => "companies#info_step"

  # ROOT
  authenticated :user do
    root to: "pages#home", as: :authenticated_root
  end
  unauthenticated do
    root 'pages#landing'
  end
  get "test" => "pages#test"
  patch "show_invit" => "pages#show_invit"

end
