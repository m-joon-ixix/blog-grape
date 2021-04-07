# Global API Helper

module BlogAPIHelper

  def current_user
    @current_user ||= authorized_user
  end

  def authorized_user
    access_token = fetch_access_token
    error!(failure_response('Access_token was not passed!'), 401) if access_token.nil?
    User.find_by_access_token(fetch_access_token)
  end

  def authenticate!
    error!(failure_response('Authentication Failed!'), 401) unless current_user
  end

  # bearer_token not defined here

  def fetch_access_token
    params[:access_token]
  end

  def success_response(message = '', data = nil)
    { success: true, message: message, data: data }
  end

  def failure_response(message = '', data = nil, code = -1)
    { success: false, message: message, data: data, code: code }
  end
end