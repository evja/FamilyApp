Rails.application.routes.draw do
  get 'members/index'
  get 'members/new'
  get 'members/create'
  get 'members/edit'
  get 'members/update'
  get 'members/show'
  get 'families/new'
  get 'families/create'
  get 'families/show'
  devise_for :users
  get 'leads/create'
  root "home#index"
  get "about", to: "home#about"
  resources :leads, only: [:create]
  resources :families, only: [:new, :create, :show, :edit, :update, :destroy]
  resources :families do
    resources :members
  end
end