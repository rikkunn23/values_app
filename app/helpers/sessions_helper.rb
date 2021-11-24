module SessionsHelper

   # 渡されたユーザーでログインする
   def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    # permanent(20年)とsigned(署名式)で強化
    cookies.permanent.signed[:user_id] = user.id
    # 長い文字列に変形されたやつをトークンで保存
    cookies.permanent[:remember_token] = user.remember_token
  end


    # 記憶トークンcookieに対応するユーザーを返す
   # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    # if session[:user_id]
    #   @current_user ||= User.find_by(id: session[:user_id])
    # end
    # @current_user = @current_user || User.find_by(id: session[:user_id])
    # ifを上のようにかけるイコールじゃなかったら何も代入されてなかったら||の後ろが処理させる
    #それをもう一段階短縮することができる
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      #cookieに情報があった場合その情報をセッションに更新する
      user = User.find_by(id: user_id)
      #user_idがcookieに更新されていた場合
      if user && user.authenticated?(:remember,cookies[:remember_token])
        #tokenとidを比較
        log_in user #user_idをセッションに更新
        @current_user = user #セッションに保存全ての情報を
      end
    end
  end

  # 渡されたユーザーがカレントユーザーであればtrueを返す
  # correct_userのunless @user == current_userの部分をわかりやすく
  def current_user?(user)
    user && user == current_user
  end


  # ユーザーがログインしていればtrue、その他ならfalseを返す
  #defcurrent_userがnilではない時にログインしている
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    #cookieから消す
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end



    # 現在のユーザーをログアウトする
    def log_out
      forget(current_user) #破棄する
        session.delete(:user_id)
        @current_user = nil #sessionの情報の中身を空にする
    end


    # ログインしていない場合にアクセスしたURLを覚えておく
  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
  #リダイレクト先があるかを演算子を使って なければdefaultに飛ばされるdefaultは(createアクション)に
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  #GETリクエストされたときにURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end


end
