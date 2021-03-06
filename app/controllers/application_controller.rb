class ApplicationController < ActionController::Base

  delegate :current_user, :user_signed_in?, :to => :user_session
  helper_method :current_user, :user_signed_in?

  # Catch all CanCan errors and alert the user of the exception
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  # include TheRole::Controller
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def user_session
    Session.new(session)
  end

  def require_authentication
    unless user_signed_in?
      redirect_to new_sessions_path, alert: t('flash.alert.needs_login')
    end
  end

  def require_no_authentication
   if user_signed_in?
      redirect_to root_path, notice: t('flash.notice.already_logged_in')
    end
  end

  private
  def current_ability
    @current_ability ||= Ability.new(current_user)
  end
  # def access_denied
  #  flash[:error] = t('the_role.access_denied')
  #   redirect_to(:back)
  # end

  protected

  # Derive the model name from the controller. egs UsersController will return User
  def self.permission
    return name = controller_name.classify.constantize
  end
end
