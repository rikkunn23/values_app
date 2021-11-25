class SessionsController < ApplicationController
  # ログインページ
  def new
  end

  # フォームからここにくるparamsの中のsessionの中のメールから全ての情報を探す
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    # 中身があるかどうかパスワードとメアドが一致するか
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user #セッションに保存 helperに定義
#ifを三項演算子で表している   # remember user #cookieに保存
#checkが入る=1=クッキーに保存
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)

      # redirect_back_or user
      redirect_to user #user_url(user)

      end
    else
      message  = 'メールアドレスまたはパスワードが違います'
      message += "Check your email for the activation link."
      flash[:warning] = message
      redirect_to root_url
    end

  end

  def destroy
    #もし自分がログインしていた時に保存情報をnilに(他のタブ問題解消)
    log_out  if logged_in?
    redirect_to root_url
  end
end
