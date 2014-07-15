class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_me!

  def authenticate_me!
    # Skip auth if you are trying to log in
    if controller_name.downcase == "accounts"
      return true
    end
    authenticate_user!
  end

  def flash_message(type, text)
    flash[type] ||= []
    flash[type] << text
  end

  private
  
  def authenticate_user_from_token!
    user_token = params[:user_token].presence
    user = user_token && User.find_by_authentication_token(user_token.to_s)
 
    if user
      sign_in user, store: false
    end
  end
end
