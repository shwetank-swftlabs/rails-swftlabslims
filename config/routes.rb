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
  namespace :experiments do
    resources :nop_processes, only: [:index, :show, :new, :create] do
      collection do
        get :batch_number
      end
      resources :images, only: [:create, :show], controller: "/images"
      resources :comments, only: [:create], controller: "/comments"
    end
  end

  # Inventory routes (proper namespace)
  namespace :inventory do
    resources :equipments, only: [:index, :new, :create, :show] do
      member do
        get :qr_code
      end 

      resources :images, only: [:create, :show], controller: "/images"
      resources :comments, only: [:create], controller: "/comments"
    end

    resources :chemicals, only: [:index, :new, :create, :show] do
      member do
        get :qr_code
      end

      resources :comments, only: [:create], controller: "/comments"
      resources :usages, only: [:create], controller: "/usages"
    end

    resources :feedstocks, only: [:index, :new, :create, :show] do
      member do
        get :qr_code
      end

      resources :images, only: [:create, :show], controller: "/images"
      resources :comments, only: [:create], controller: "/comments"
      resources :usages, only: [:create], controller: "/usages"
      resources :data_files, only: [:create, :show], controller: "/data_files"
    end
  end
end
