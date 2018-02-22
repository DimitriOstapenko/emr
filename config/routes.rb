Rails.application.routes.draw do

  root 'static_pages#home'
#  root 'patients#index'
  
  get '/procedures/index' => 'procedures#find', constraints: { query_string: /findstr/ }
  get 'procedures/new'
  get 'procedures/show'
  get 'procedures/index'
  get 'procedures/edit'
#
  get '/diagnoses/index' => 'diagnoses#find', constraints: { query_string: /findstr/ }
  get 'diagnoses/new'
  get 'diagnoses/show'
  get 'diagnoses/index'
  get 'diagnoses/edit'

  get '/doctors/index' => 'doctors#find', constraints: { query_string: /findstr/ }
  get 'doctors/new'
  get 'doctors/show'
  get 'doctors/index'
  
  post '/daysheet/index', to: 'daysheet#set_doctor' 
  get '/set_doctor', to: 'daysheet#set_doctor' 
  get 'daysheet/index'

#  get 'sessions/new'
# get 'users/new'

  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get '/patients(/:id)', to: 'patients#find', constraints: { query_string: /findstr/ }
  patch '/patients(/:id)', to: 'patients#find', constraints: { query_string: /findstr/ }
  post  '/patients(/:id)/card', to: 'patients#card'
  get '/patients(/:id)/card', to: 'patients#card'

  get  '/patsignup', to: 'patients#new'
  post '/patsignup', to: 'patients#create'

 get '/visits' => 'visits#daysheet', constraints: { query_string: /date/ }
 get '/visits' => 'visits#index'
 get '/billings' => 'billings#index'
#   get '/daysheet', :to => redirect { |params, request| "/visits/?#{request.params.to_query}" }

  resources :users
  resources :patients do
#    scope :ujs, defaults: { format: :ujs } do
#      patch 'card' => 'patients#card'
#    end

    get 'label', on: :member
    resources :visits do  # , shallow: true         #, only: [:show, :create, :destroy, :new, :index]
      get 'visitform', on: :member
    end
  end
  resources :doctors
  resources :diagnoses
  resources :procedures
#  resources :billings
  
end
