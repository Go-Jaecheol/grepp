Rails.application.routes.draw do
  resources :reservations do
    get :available, on: :collection
    patch :confirm, on: :member
  end
end
