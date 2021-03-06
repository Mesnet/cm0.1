Rails.application.routes.draw do
  
  #TASKS
  resources :tasks do 
    member do 
      patch :post_select
      patch :post_change
      patch :done 
      patch :undone
      patch :participate
      patch :unparticipate
      patch :delparticipate
      patch :show_sn
    end
  end
  
  resources :task_reminds

  resources :sub_tasks do 
    member do 
      patch :done 
      patch :undone
    end 
  end

  # QUESTIONS
  resources :questions do 
    member do 
      patch :vote
      patch :unvote
      patch :revote
    end
  end
  
  # POSTS
  resources :posts
  patch "new_post_question" => "posts#new_question"
  patch "new_post_task" => "posts#new_task"
  patch "new_post_event" => "posts#new_event"

  # GROUPS
  resources :groups do 
    member do 
      patch :fav
      patch :unfav
      patch :editor
      patch :upd_role
      patch :join
      patch :unjoin 
      patch :quit
      patch :expel
      patch :acc_req
      patch :den_req
      patch :invit 
      patch :uninvit
      patch :acc_invit
      patch :den_invit
      patch :new_element
      patch :show_done_tasks
      get :taskboard
      get :calendar
      get :cloud
    end
    resources :group_users, path: :users, module: :groups
  end

  patch "elm_upd" => "groups#elm_upd"
  patch "elm_del" => "groups#elm_del"
  get "other_groups" => "groups#other_groups"
  get "other_groups_out" => "groups#other_groups_out"
  patch "show_new_group" => "groups#show_new_group"
  patch "show_fav_group" => "groups#show_fav_group"

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
    root to: "groups#index", as: :authenticated_root
  end
  unauthenticated do
    root 'pages#landing'
  end
  get "test" => "pages#test"
  patch "show_invit" => "pages#show_invit"

end
