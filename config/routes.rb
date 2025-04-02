Rails.application.routes.draw do
  root "home#index"
  get "about", to: "home#about"

  devise_for :users

  resources :leads, only: [:create]

  resources :families do
    resources :members
    resources :issues
  end
end