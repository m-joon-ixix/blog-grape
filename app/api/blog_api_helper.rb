# Global API Helper

module BlogAPIHelper

  # if @current_user doesn't exist, find the current user by invoking method 'authorized_user'
  # @return [User] the current user
  def current_user
    @current_user ||= authorized_user
  end

  # fetches the access_token given as param, finds the corresponding user, and passes it to 'current_user'
  # @return [User]
  def authorized_user
    access_token = fetch_access_token
    error!(failure_response('Access_token was not passed!'), 401) if access_token.nil?
    User.find_by_access_token(fetch_access_token)
  end

  # authenticates the user, invoking 'current_user' method
  # @return [void] if authentication fails, error raised
  def authenticate!
    error!(failure_response('Authentication Failed!'), 401) unless current_user
  end

  # bearer_token not defined here

  # fetches the parameter :access_token given, and passes it to 'authorized_user'
  # @return [String] parameter :access_token
  def fetch_access_token
    params[:access_token]
  end

  # returns a success response with the json data given
  # @param [String, JSON]
  # @return [Hash]
  def success_response(message = '', data = nil)
    { success: true, message: message, data: data }
  end

  # returns a failure response with the message given
  # @param [String, JSON, Integer]
  # @return [Hash]
  def failure_response(message = '', data = nil, code = -1)
    { success: false, message: message, data: data, code: code }
  end
end