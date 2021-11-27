class User < ApplicationRecord #ActiveRecordが適用
    #読み書きのできる仮想の属性
    attr_accessor :remember_token, :activation_token, :reset_token
    before_save   :downcase_email
    before_create :create_activation_digest

    # ユーザーがマイクロポストを複数所有する（has_many）関連付け
    # dependent: :destroyはユーザーが削除された時にそのユーザーに紐付いたマイクロポストも消される
    has_many :microposts, dependent: :destroy


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
  def feed
    # id属性は単なる整数（すなわちself.idはユーザーのid）
    Micropost.where("user_id = ?", id)
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



    #トークルーム
    # throughオプションは中間テーブルを経由して関連先のモデルを取得
    has_many :messages
    has_many :entries
    has_many :rooms, through: :entries
end
