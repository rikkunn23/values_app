Rails.application.routes.draw do

  get 'password_resets/new'
  get 'password_resets/edit'
  get 'session/new'
root 'static_pages#home'

# get 'static_pages/help'
# /helpにアクセスしたときにstatic_pagesのヘルプメソッドをもってくる
get  '/home',    to: 'static_pages#home'
get  '/help',    to: 'static_pages#help'
get  '/about',   to: 'static_pages#about'
get  '/contact', to: 'static_pages#contact'
get  '/signup',  to: 'users#new'

get    '/login',   to: 'sessions#new'
post   '/login',   to: 'sessions#create'
delete '/logout',  to: 'sessions#destroy'



resources :users
resources :account_activations, only: [:edit] #ユーザーの承認メールはupdateではなくGETで送信されるためにeditを使っている

resources :password_resets,     only: [:new, :create, :edit, :update]

resources :microposts,          only: [:create, :destroy]
# POST	/microposts	create	microposts_path
# DELETE	/microposts/1	destroy	micropost_path(micropost)
end
