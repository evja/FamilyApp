Rails.application.routes.draw do
  root "home#index"
  get "about", to: "home#about"

  devise_for :users

  resources :leads, only: [:create]

  resources :families do
    resources :members do
      member do
        post :invite
        post :resend_invite
      end
    end
    
    resources :issues do
      collection do
        get :solve
      end
      member do
        patch :advance_status
      end
    end
    resources :issue_assists, only: [:create]

    resources :rhythms do
      collection do
        get :setup
        post :update_setup
      end
      member do
        post :start
        get :run
        post :check_item
        post :uncheck_item
        post :finish
        post :skip
      end
      resources :agenda_items, only: [:new, :create, :edit, :update, :destroy]
    end

    resources :family_invitations, only: [:new, :create, :destroy]
    resource :vision, controller: 'family_visions', only: [:show, :edit, :update] do
      post :assist, on: :member
      resources :values, controller: 'family_values', except: [:show]
    end
  end

  get 'invitations/:token/accept', to: 'family_invitations#accept', as: :accept_family_invitation

  get 'billing', to: 'billing#index'
  post "billing/checkout", to: "billing#checkout", as: :checkout

  post 'admin/toggle_view_as_user', to: 'application#toggle_view_as_user', as: :toggle_view_as_user

  namespace :admin do
    get 'leads/index'
    get "dashboard", to: "dashboard#index", as: :dashboard
    resources :leads, only: [:index] do # <-- Admin-only view
      collection do
        get :export
      end
    end
  end

end