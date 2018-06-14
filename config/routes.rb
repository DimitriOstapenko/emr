Rails.application.routes.draw do

  root 'static_pages#home'

  get '/daily_charts/index' => 'daily_charts#find', constraints: { query_string: /findstr/ }
  get '/daily_charts/index'
  get '/drugs/index' => 'drugs#find', constraints: { query_string: /findstr/ }
  get '/drugs/index' 
  get '/providers/index' => 'providers#find', constraints: { query_string: /findstr/ }
  get '/providers/index' 
  get '/reports/index' => 'reports#find', constraints: { query_string: /findstr/ }
  get '/reports/index' 
  get '/procedures/index' => 'procedures#find', constraints: { query_string: /findstr/ }
  get '/procedures/index' 
  get '/diagnoses/index' => 'diagnoses#find', constraints: { query_string: /findstr/ }
  get '/diagnoses/index' 
  get '/doctors/index' => 'doctors#find', constraints: { query_string: /findstr/ }
  get '/doctors/index' 
  post '/daysheet/index', to: 'daysheet#set_doctor' 
  get '/set_doctor', to: 'daysheet#set_doctor' 
  get '/daysheet/index', to: 'daysheet#index', as: :daysheet
  get '/vaccines/index', to:  "vaccines#find", constraints: { query_string: /findstr/ }
  get '/vaccines/index' 
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
 # patch '/patients(/:id)', to: 'patients#find', constraints: { query_string: /findstr/ }
  post  '/patients(/:id)/card', to: 'patients#card'
  get '/patients(/:id)/card', to: 'patients#card'

  get  '/patsignup', to: 'patients#new'
  post '/patsignup', to: 'patients#create'

 get '/visits' => 'visits#daysheet', constraints: { query_string: /date/ }
 get '/visits' => 'visits#index'
 get '/billings' => 'billings#index'
 post '/billings/export_csv', to: 'billings#export_csv'
 post '/billings/export_edt', to: 'billings#export_edt'
 post '/billings/export_cabmd', to: 'billings#export_cabmd'
 get "/procedures/get_by_code", to: "procedures#get_by_code" 

#   get '/daysheet', :to => redirect { |params, request| "/visits/?#{request.params.to_query}" }

  resources :users
  resources :patients do
    get 'label', on: :member
    get 'chart', on: :member
    resources :visits do  # , shallow: true         #, only: [:show, :create, :destroy, :new, :index]
      get 'visitform', on: :member
      get 'receipt', on: :member
      get 'invoice', on: :member
      get 'referralform', on: :member
      get 'sendclaim', on: :member
    end
  end
  
  resources :doctors
  resources :diagnoses
  resources :procedures
  resources :reports do
     get 'export', on: :member
     get 'show_pdf', on: :member
  end
  resources :providers
  resources :drugs
  resources :invoices
  resources :vaccines
  resources :daily_charts
  resources :export_files

# resources :billings     # historical billing table - not used
  
end
