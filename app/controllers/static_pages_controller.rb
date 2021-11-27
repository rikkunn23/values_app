class StaticPagesController < ApplicationController
  def home
    if logged_in?
    # current_userはユーザーがログインしていないと使えない
    @micropost = current_user.microposts.build
    @feed_items = current_user.feed.paginate(page: params[:page])
    # feedメソッドでwhereで情報をとってきて入れている
    end
  end


  def help
  end

  def about
  end

  def contact
  end


end
