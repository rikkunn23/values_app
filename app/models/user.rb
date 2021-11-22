class User < ApplicationRecord #ActiveRecordが適用

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
    validates :password, presence: true, length: { minimum: 8 }
end
