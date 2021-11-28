class User < ApplicationRecord #ActiveRecordが適用
  # ユーザーがマイクロポストを複数所有する（has_many）関連付け
  # dependent: :destroyはユーザーが削除された時にそのユーザーに紐付いたマイクロポストも消される
  has_many :microposts, dependent: :destroy


  #Railsはデフォルトでは外部キーの名前を<class>_idといったパターンとして理解
  # 前はuser_idとuserというDBがありuserがあったが
  #今回はfollowというクラスは存在しないので定義する必要がある

# AはBをフォローBはAをフォロバしていない
# AはBに対して「能動的関係」（Active Relationship）
# BはAに対して「受動的関係」（Passive Relationship）

# フォローしているユーザー
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
#ユーザーを削除したら、ユーザーのリレーションシップも同時に削除される必要がある
                                  dependent:   :destroy
  # ユーザーが削除された時にそのユーザーに紐付いたマイクロポストも消される

  # 受動的関係
  has_many :passive_relationships, class_name:  "Relationship",
                                  foreign_key: "followed_id",
                                  dependent:   :destroy
#has_many :followeds, through: :active_relationships
  # railsはfollowedというシンボル名を見て、これを「followed」という単数形に変換し
#relationshipsテーブルのfollowed_idを使って対象のユーザーを取得
# 名前は英語として不適切。代わりにuser.followingを使うために
# :sourceパラメーター「following配列の元はfollowed idの集合である」＝配列で扱える
# 　フォローしているユーザー
has_many :following, through: :active_relationships, source: :followed
# 受動的関係
has_many :followers, through: :passive_relationships, source: :follower
# :followedと:followerの情報を分けてuserに返している


#読み書きのできる仮想の属性
    attr_accessor :remember_token, :activation_token, :reset_token
    before_save   :downcase_email
    before_create :create_activation_digest



    before_save { self.email = self.email.downcase}
    #中身があるかどうか 長さなど ハッシュは()省略
    validates :name,  presence: true, length: { maximum: 50 }
    EMAIL_REGEX =  /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
    format: { with: EMAIL_REGEX },
    # 一意性とメールアドレスの大文字・小文字の区別を無くす
    uniqueness: { case_sensitive: false }

    #パスワード
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

      # 渡された文字列のハッシュ値を返す
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    def User.new_token
        SecureRandom.urlsafe_base64
    end

  # 永続セッションのためにユーザーをデータベースに記憶する
    def remember
        self.remember_token = User.new_token
#attr_accessorとselfを使い仮想的な属性を使っている
        update_attribute(:remember_digest, User.digest(remember_token))
#:remember_digestにハッシュ化したトークンを保存している
      end


       # 渡されたトークンがダイジェストと一致したらtrueを返す
       def authenticated?(attribute, token)
        digest = self.send("#{attribute}_digest")
        return false if digest.nil?
# //////returnを使ってここで処理を止めている他のブラウザの対策//////////

    # BCrypt::Password.new(remember_digest) == remember_token
    # bcryptは比較に使っている==演算子が再定義
    # ==の代わりにis_password?という論理値メソッド
    # session==cookie remember_tokenはcookieに更新されたsessions_helper参照
    # BCrypt::Password.new(remember_digest).is_password?(remember_token)
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  #DBのトークンをnilにする
  def forget
    update_attribute(:remember_digest, nil)
  end


    # アカウントを有効にする DBを更新
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

    # 有効化用のメールを送信する
    def send_activation_email
      UserMailer.account_activation(self).deliver_now
    end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

    def send_password_reset_email
      UserMailer.password_reset(self).deliver_now
    end

    # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    #2時間より早いというニュアンスで
    reset_sent_at < 2.hours.ago
  end


  # すべてのユーザーがフィードを持つので、feedメソッドはUserモデルで作る
  # 現在ログインしているユーザーのマイクロポストをすべて取得
  # 試作feedの定義
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  # SQL文に変数を代入する場合は常にエスケープする

    # id属性は単なる整数（すなわちself.idはユーザーのid）
     # ユーザーのステータスフィードを返す

  def feed
    # 配列をマップで回してフォローのIDを取得＝数が膨大になった場合がきついSELECTを使う
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end

   # ユーザーをフォローする
  # source:にてfollowingは配列になったため<<で最後に追加できる
  def follow(other_user)
    following << other_user
  end


    # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = email.downcase
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end


end
