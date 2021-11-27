class UsersController < ApplicationController
#アクションを起こしたい時を指定できる
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy #管理者


  # 全てのユーザーを照会
  def index
    @users = User.paginate(page: params[:page])
    # @users = User.all
  end


# 参照
  def show
    @user = User.find(params[:id])
    # インスタンス変数をUsersコントローラで定義
    @microposts = @user.microposts.paginate(page: params[:page])
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
      @user.send_activation_email #メールを送信する モデルに定義

      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url

      # log_in @user #作成してdbからセッションを参照して一致したら
      # flash[:success] = "アカウントが作成されました！valuseへようこそ"
      # redirect_to @user
      #redirect_to user_url(@user)
    else
      render 'new'
    end
  end


  def edit
    @user = User.find(params[:id])
  end


  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "プロフィールを更新しました"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "ユーザーを削除しました"
    redirect_to users_url
  end



  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation)
    end



        # 正しいユーザーかどうか確認
        def correct_user
          @user = User.find(params[:id])
          redirect_to(root_url) unless current_user?(@user)
          # redirect_to(root_url) unless @user == current_user
        end

        #管理者なのかを確認
        def admin_user
          redirect_to(root_url) unless current_user.admin?
        end


end
