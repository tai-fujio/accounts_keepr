Rails.application.routes.draw do
  resources :records
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users
  resources :users, only: [:show]
  root to: "home#index"
end
