class UsersController < ApplicationController

# 参照
  def show
    @user = User.find(params[:id])
  end

#newcreate
  def new
      @user = User.new
  end

  # formでPOSTリクエストを/usersというURLに送信されcreateアクションに送られる
 #params[:user]として生身でそのまま情報が入るのは危険だからuser_paramsをprivateで定義し置き換える
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "アカウントが作成されました！valuseへようこそ"
      redirect_to @user
      #redirect_to user_url(@user)
    else
      render 'new'
    end
  end



  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation)
    end
end
