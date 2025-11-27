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
  # NOP Processes routes
  get "/experiments/nop-processes", to: "experiments/nop_processes#index", as: :nop_processes
  get "/experiments/nop-processes/:id", to: "experiments/nop_processes#show", as: :nop_process

  # Inventory routes
  # Equipments routes
  get "/inventory/equipments", to: "inventory/equipments#index", as: :equipments
  get "/inventory/equipments/new", to: "inventory/equipments#new", as: :new_equipment
  post "/inventory/equipments", to: "inventory/equipments#create"
end
