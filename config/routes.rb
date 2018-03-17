Rails.application.routes.draw do

  get '/reports/index' => 'reports#find', constraints: { query_string: /findstr/ }
  get 'reports/index'
  get 'reports/new'
  get 'reports/show'
#  get 'reports/create'

  root 'static_pages#home'
#  root 'patients#index'
  
  get '/procedures/index' => 'procedures#find', constraints: { query_string: /findstr/ }
  get 'procedures/index'
  get 'procedures/new'
  get 'procedures/show'
  get 'procedures/edit'

  get '/diagnoses/index' => 'diagnoses#find', constraints: { query_string: /findstr/ }
  get 'diagnoses/index'
  get 'diagnoses/new'
  get 'diagnoses/show'
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
  get  '/news', to: 'static_pages#news'
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
 post '/billings/export_csv', to: 'billings#export_csv'
 post '/billings/export_edt', to: 'billings#export_edt'

#   get '/daysheet', :to => redirect { |params, request| "/visits/?#{request.params.to_query}" }

  resources :users
  resources :patients do
    get 'label', on: :member
    get 'chart', on: :member
    resources :visits do  # , shallow: true         #, only: [:show, :create, :destroy, :new, :index]
      get 'visitform', on: :member
      get 'receipt', on: :member
    end
  end
  resources :doctors
  resources :diagnoses
  resources :procedures
  resources :reports

 resources :billings     # historical billing table
  
end
