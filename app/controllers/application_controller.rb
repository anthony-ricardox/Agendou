class ApplicationController < ActionController::Base
  helper_method :current_user

  allow_browser versions: :modern

  stale_when_importmap_changes

  private

  def current_user
    return nil unless session[:user_id]

    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to new_session_path, alert: "Você precisa entrar para continuar"
    end
  end
end