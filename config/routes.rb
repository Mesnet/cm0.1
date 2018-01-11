Rails.application.routes.draw do
 
  resources :groups do 
    member do 
    end 
    resources :group_users, path: :users, module: :groups
  end

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
    resources :company_users, path: :users, module: :companies
  end

  get "company_invit" => "companies#company_invit"
  get "company_manage" => "companies#new"
  patch "info_step" => "companies#info_step"

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
