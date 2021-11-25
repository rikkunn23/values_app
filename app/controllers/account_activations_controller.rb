class AccountActivationsController < ApplicationController
# メールでクリックされてアクセスされたらここにくるparams[:id]として参照
    def edit
      user = User.find_by(email: params[:email])
      if user && !user.activated? && user.authenticated?(:activation, params[:id])
        user.activate #アカウントをDBに保存し有効にするtrueに
        log_in user
        flash[:success] = "Account activated!"
        redirect_to user
      else
        flash[:danger] = "Invalid activation link"
        redirect_to root_url
      end
    end

  end
