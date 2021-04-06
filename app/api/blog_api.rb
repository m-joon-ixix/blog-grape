class BlogAPI < BaseGrapeAPI
  format :json
  default_format :json

  helpers BlogAPIHelper
  # before : :access_token = bearer_token if acc_tok.is_not_nil && bearer_token

  mount ::V1::Base
end
