Rails.application.routes.draw do
  devise_for :users
  
  namespace :admin do
    root to: 'dashboard#index'
    post 'toggle_aceite_automatico', to: 'dashboard#toggle_aceite_automatico', as: :toggle_aceite_automatico
    get 'test', to: 'dashboard#index'  # Rota de teste simples
    
    # Configurações de agendamento
    get 'scheduling', to: 'scheduling#index'
    patch 'scheduling/configuration', to: 'scheduling#update_configuration'
    patch 'scheduling/availability', to: 'scheduling#update_availability'
    post 'scheduling/move_orders_to_production', to: 'scheduling#move_orders_to_production'
    get 'test-scheduling', to: 'scheduling#index'
    
    resources :products do
      member do
        get :confirm_destroy
      end
    end
    resources :orders do
      member do
        post :accept
        patch :update_status
        post :cancel_scheduled_order
      end
    end
    resources :customers
    resources :categories
  end

  namespace :api do
    resources :orders, only: [:create]
  end

  root to: 'admin/dashboard#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
