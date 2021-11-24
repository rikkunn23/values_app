class ApplicationController < ActionController::Base
    # セッションヘルパーがどこでも使えるようにする
    include SessionsHelper
end
