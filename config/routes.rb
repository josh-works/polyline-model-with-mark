Rails.application.routes.draw do
  get 'activity/index'
  
  get 'activity/:id', to: 'activity#show', as: 'activity_show'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'activity#index'
end
