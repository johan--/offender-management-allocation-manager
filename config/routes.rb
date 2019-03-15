Rails.application.routes.draw do
  root to: 'dashboard#index'

  match "/401", :to => "errors#unauthorized", :via => :all
  match "/404", :to => "errors#not_found", :via => :all, constraints: lambda { |req| req.format == :html }
  match "/500", :to => "errors#internal_server_error", :via => :all
  match "/503", :to => "errors#internal_server_error", :via => :all

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/signout', to: 'sessions#destroy'
  get('/prisoners/:id' => 'prisoners#show', as: 'prisoners_show')
  get('/allocations/confirm/:nomis_offender_id/:nomis_staff_id' => 'allocations#confirm', as: 'confirm_allocations')
  get('/poms/my_caseload' => 'poms#my_caseload', as: 'my_caseload')
  get('/poms/new_cases' => 'poms#new_cases', as: 'new_cases')

  get('/summary' => 'summary#index')
  get('/summary/allocated' => 'summary#allocated')
  get('/summary/unallocated' => 'summary#unallocated')
  get('/summary/pending' => 'summary#pending')

  get('/search' => 'search#search')

  get('/prisons' => 'prisons#index')
  get('/prisons/update' => 'prisons#set_active')

  resources :health, only: %i[ index ], controller: 'health'
  resources :status, only: %i[ index ], controller: 'status'
  resource :overrides,  only: %i[ new create ], path_names: { new: 'new/:nomis_offender_id/:nomis_staff_id'}
  resources :poms, only: %i[ index show edit update ], param: :nomis_staff_id
  resource :allocations, only: %i[ new create edit ], path_names: {
    new: 'new/:nomis_offender_id',
    edit: 'edit/:nomis_offender_id',
    confirm: 'confirm/:nomis_offender_id/:nomis_staff_id'
  }
  resource :case_information, only: %i[new create edit update], controller: 'case_information', path_names: {
      new: 'new/:nomis_offender_id',
      edit: 'edit/:nomis_offender_id'
  }
end
