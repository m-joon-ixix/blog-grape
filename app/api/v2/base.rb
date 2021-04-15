module V2
  class Base < ::BaseGrapeAPI
    mounted do
      version 'v2', using: :path

      mount ::V2::Admin
      mount ::V2::Mypage
      mount ::V2::Users
      mount ::V2::Categories
      mount ::V2::Posts
      mount ::V2::Comments
    end
  end
end
