class Micropost < ApplicationRecord
  # user:referencesを打って作成したことにより
  # ユーザーと１対１の関係であることを表すbelongs_toが追加
  # user_idcreated_atupdated_atというカラムが追加
  belongs_to :user
  # @user.microposts.buildのようなコードを使うためには、
  # /UserモデルとMicropostモデルをそれぞれ更新して、関連付ける
  #マイグレーションで生成される

  # Active Storageを使う際にファイルを関連付けるのに必要になってくる
  # has_many_attachedだと一回につき複数いける
  has_one_attached :image




  default_scope -> { order(created_at: :desc) }
  # default_scopeを使い最も新しいマイクロポストを最初に表示
  # ->というラムダ式 callメソッドが呼ばれたとき、ブロック内の処理


  validates :user_id, presence: true #が存在しているかどうか
  validates :content, presence: true, length: { maximum: 140 }

  # ontent_typeを検査することで画像をバリデーションできる
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size:         { less_than: 5.megabytes,
                                      message: "should be less than 5MB" }



  # 表示用のリサイズ済み画像を返す
  # resize_to_limitオプションを使って幅や高さ500ピクセル超えないようにする
  def display_image
    image.variant(resize_to_limit: [500, 500])
  end


end
