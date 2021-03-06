class ApplicationController < ActionController::Base
    # セッションヘルパーがどこでも使えるようにする
    include SessionsHelper



    private
 # ログイン済みユーザーかどうか確認
 #ログインしていないユーザーに書き加えられてしまっては困る
 def logged_in_user
    unless logged_in?
      store_location #url保存
      flash[:danger] = "ログインしてください"
      redirect_to login_url
    end
  end

  # UsersControllerとStaticPagesControllerの両方から利用
  def microposts_search_params
    params.require(:q).permit(:content_cont)
  end

end
