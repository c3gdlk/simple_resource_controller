Rails.application.routes.draw do
  resources :users
  resources :admin_articles
  resources :another_articles
  resources :articles do
    resources :comments
    resources :recent_comments
  end

  resources :post_comments
end
