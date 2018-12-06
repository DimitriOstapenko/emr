Rails.application.routes.draw do

  root 'static_pages#home'


  get 'password_resets/new'
  get 'password_resets/edit'

  get '/ra_messages/index(/:id)' => 'ra_messages#find', constraints: { query_string: /findstr/ }
  get 'ra_messages/index'
  
  get '/forms/index(/:id)' => 'forms#find', constraints: { query_string: /findstr/ }
  get '/forms/index'

  get '/claims/index(/:id)' => 'claims#find', constraints: { query_string: /findstr/ }
  get '/claims/index' 
  post '/claims/index' 

  get '/charts/index' => 'charts#find', constraints: { query_string: /findstr/ }
  get '/charts/index'

  get '/daily_charts/index' => 'daily_charts#find', constraints: { query_string: /findstr/ }
  get '/daily_charts/index'
  post '/daily_charts/index'
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
 # post '/daysheet/index', to: 'sessions#set_doctor' 
  post '/set_doctor', to: 'sessions#set_doctor'
  get '/set_doctor', to: 'sessions#set_doctor' 
  get '/daysheet/index', to: 'daysheet#index', as: :daysheet
  get '/vaccines/index', to:  "vaccines#find", constraints: { query_string: /findstr/ }
  get '/vaccines/index' 
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/news', to: 'static_pages#news'
  get  '/terms', to: 'static_pages#terms'
  get  '/privacy', to: 'static_pages#privacy'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'

  get  '/switch_to/:id', to: 'sessions#switch_to', as: :switch_user

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get '/patients(/:id)', to: 'patients#find', constraints: { query_string: /findstr/ }
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
  get "/procedures/get", to: "procedures#get" 
  
  resources :users
  resources :patients do
    get 'label', on: :member
    get 'addrlabel', on: :member
    get 'chart', on: :member
    resources :invoices do
      get 'invoice', on: :member
    end
    resources :letters 
    resources :referrals 
    resources :charts
    resources :visits do  # , shallow: true         #, only: [:show, :create, :destroy, :new, :index]
      get 'visitform', on: :member
      get 'receipt', on: :member
#      get 'referralform', on: :member
      get 'sendclaim', on: :member
      get 'addcash', on: :member
      resources :documents
    end
  end
  
  resources :ra_messages, :ra_accounts, :ra_errcodes, :doctors, :diagnoses, :procedures, :providers, 
	    :drugs, :vaccines, :export_files, :claim_errors

  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  resources :claims do
    resources :services
  end

  resources :reports do
     get 'export', on: :member
     get 'download', on: :member
  end

  resources :paystubs do
     get 'export', on: :member
     get 'download', on: :member
  end
  get 'budget', to: 'paystubs#budget'

  resources :edt_files do
     get 'download', on: :member
  end

  resources :forms do
     get 'download', on: :member
  end
  
  resources :invoices do
     get 'download', on: :member
  end
  
  resources :letters do
     get 'download', on: :member
  end
  
  resources :referrals do
     get 'download', on: :member
  end

  resources :daily_charts do
     get 'download', on: :member
  end

  resources :charts do
     get 'download', on: :member
  end
  
  resources :schedules

# resources :billings     # historical billing table - not used
  
end
