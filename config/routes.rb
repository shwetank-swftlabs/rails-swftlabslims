Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: :health_check

  # Authentication routes
  get "/login", to: "sessions#new"
  get "/auth/google_oauth2/callback", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  root "experiments#index"

  # Top level routes
  get "/experiments", to: "experiments#index", as: :experiments
  get "/inventory", to: "inventory#index", as: :inventory
  get "/products", to: "products#index", as: :products

  # Experiments routes
  get "/experiments/nop-processes", to: "experiments/nop_processes#index", as: :nop_processes
  get "/experiments/nop-processes/:id", to: "experiments/nop_processes#show", as: :nop_process

  # Inventory routes (proper namespace)
  namespace :inventory do
    resources :equipments, only: [:index, :new, :create, :show]
  end
end
