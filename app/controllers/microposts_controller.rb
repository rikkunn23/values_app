class MicropostsController < ApplicationController
    protect_from_forgery
    # logged_in_userメソッド
    before_action :logged_in_user, only: [:create, :destroy]

    # correct_userフィルター内でfindメソッドを呼び出すことで、
    # 現在のユーザーが削除対象のマイクロポストを保有しているかどうかを確認します
    before_action :correct_user,   only: :destroy


    def create
        # buildはnewみたいなもの
        @micropost = current_user.microposts.build(micropost_params)

        # @micropostオブジェクトにアタッチ
#  アップロードを許可するために、micropost_paramsメソッドを更新して:imageを許可済み属性リストに追加
        @micropost.image.attach(params[:micropost][:image])

        if @micropost.save
          flash[:success] = "Micropost created!"
          redirect_to root_url
        else
        @q = Micropost.none.ransack
        @feed_items = current_user.feed.paginate(page: params[:page])
          render 'static_pages/home'
        end
      end

      def destroy
        micropost = Micropost.find(params[:id])
        micropost.destroy

        flash[:success] = "ツイートを削除しました。"
        #削除した後ホームに戻らないようにしている
#request.referrer は一つ前のURLを返します
        redirect_to request.referrer || root_url

      end

      private

        def micropost_params
            # フォームなどによって送られてきた情報（パラメーター）を取得する
            params.require(:micropost).permit(:content, :image)
        #   params.require(:micropost).permit(:content)
        end

# faindを使い削除対象のものを所持しているかどうかを確認
# before_actionで定義されているためdeleteをすると先に処理されるなかった場合削除はされず返される
        def correct_user
            @micropost = current_user.microposts.find_by(id: params[:id])
            redirect_to root_url if @micropost.nil?
        end

    end
