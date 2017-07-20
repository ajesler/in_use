Rails.application.routes.draw do
  resources :things, only: [:index, :show, :update] do
    member do
      post :slack, to: 'things#slack'
    end
  end
end
