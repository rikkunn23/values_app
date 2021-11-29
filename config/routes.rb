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

post "/microposts", to: 'microposts#create'
delete "/microposts/:id" => 'microposts#destroy'

resources :users do
  # memberメソッドを使うとユーザーidが含まれているURLを扱う
  # すべてのメンバーを表示するには、次のようにcollectionメソッドを使う
  member do
 # どちらもデータを表示するページなので、適切なHTTPメソッドはGET
    get :following, :followers
  end
end

# HTTPリクエスト	URL	　　　　　　　　　アクション	名前付きルート
# GET	　　　　　　/users/1/following	following	following_user_path(1)
# GET	　　　　　　/users/1/followers	followers	followers_user_path(1)

resources :users
resources :account_activations, only: [:edit] #ユーザーの承認メールはupdateではなくGETで送信されるためにeditを使っている

resources :password_resets,     only: [:new, :create, :edit, :update]

# resources :microposts,          only: [:create, :destroy]
# POST	/microposts	create	microposts_path
# DELETE	/microposts/1	destroy	micropost_path(micropost)

resources :relationships,       only: [:create, :destroy]

end
