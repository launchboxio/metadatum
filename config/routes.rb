Rails.application.routes.draw do
  scope module: :api, defaults: { format: :json }, path: 'api' do
    namespace :v1 do
      resources :metadata
    end
  end
end
