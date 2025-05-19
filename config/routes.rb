Rails.application.routes.draw do
  root "home#index"
  get "about", to: "home#about"

  devise_for :users

  resources :leads, only: [:create]

  resources :families do
    resources :members
    resources :issues
    resources :family_invitations, only: [:new, :create, :destroy]
  end

  get 'invitations/:token/accept', to: 'family_invitations#accept', as: :accept_family_invitation

  get 'billing', to: 'billing#index'
  post "billing/checkout", to: "billing#checkout", as: :checkout

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