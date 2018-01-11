Rails.application.routes.draw do

  get 'doctors/new'

  get 'doctors/show'

  get 'doctors/index'

  get 'daysheet/index'

#  get 'sessions/new'
# get 'users/new'

  root 'static_pages#home'
#  root 'patients#index'
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

#  post '/patients/:findbox' =>  'patients#find'
#  get  '/patients/:lname', to: 'patients#show', as: :patient
   get '/patients' => 'patients#find', constraints: { query_string: /findstr/ }
   get '/patients' => 'patients#daysheet', constraints: { query_string: /date/ }
   #resources :patients 

  #post '/patients',  to: 'patients#index'
  get  '/patsignup', to: 'patients#new'
  post '/patsignup', to: 'patients#create'

#  get '/daysheet',  to: 'patients#daysheet'
   get '/daysheet', :to => redirect { |params, request| "/patients/?#{request.params.to_query}" }

  resources :users
  resources :patients
  resources :doctors
  resources :visits, only: [:show, :create, :destroy]

end
