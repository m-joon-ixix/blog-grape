Rails.application.routes.draw do
  get '', to: 'main#index'

  devise_for :users
  ActiveAdmin.routes(self)

  authenticate :user do

  end

  mount BlogAPI => '/'
end
