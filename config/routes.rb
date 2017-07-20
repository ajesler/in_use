Rails.application.routes.draw do
  resources :things, only: [:index, :show, :update] do
    member do
      post :slack, to: 'things#slack'
      put :free, to: 'things#free'
      put :in_use, to: 'things#in_use'
    end
  end
end
