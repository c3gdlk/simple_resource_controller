Rails.application.routes.draw do
  resources :users
  resources :admin_articles
  resources :another_articles
  resources :some_articles
  resources :articles do
    resources :comments
    resources :recent_comments
  end

  resources :post_comments

  namespace :api do
    resources :articles
    resources :another_articles
    resources :some_articles do
      collection do
        get :index2
      end

      member do
        get :show2
      end
    end
  end
end
