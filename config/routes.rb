Rails.application.routes.draw do
  resources :reservations do
    get :available, on: :collection
    patch :confirm, on: :member
    patch :cancel, on: :member
  end
end
