class RelationshipsController < ApplicationController
    before_action :logged_in_user


    # followされた時
    def create
        user = User.find(params[:followed_id])
        current_user.follow(user)
        redirect_to user
        # # Ajaxに対応
        # respond_to do |format|
        #     format.html {　redirect_to @user　}
        #     format.js
        #   end
      end
# unfollow
      def destroy
        user = Relationship.find(params[:id]).followed
        current_user.unfollow(user)
        redirect_to user
        # Ajaxに対応
        # respond_to do |format|
        #     format.html { redirect_to @user }
        #     format.js
        #   end
      end
  end
