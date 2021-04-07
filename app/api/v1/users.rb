module V1
  class Users < BaseGrapeAPI
    mounted do
      before { authenticate! }
      params { requires :access_token, type: String, desc: '엑세스 토큰' }

      namespace :user do
        desc '현재 사용자 조회', entity: ::V1::Entities::User
        get do
          represented = ::V1::Entities::User.represent(current_user)
          success_response(nil, represented.as_json)
        end

        desc '특정 사용자 조회', entity: ::V1::Entities::User
        params { requires :id, type: String, desc: '검색할 사용자 ID. 콤마로 구분' }
        get ':id' do
          ids = params[:id].split(',').map(&:to_i)
          # DASHBOARD인 유저는 모든 검색 가능. 그렇지 않으면 본인만 검색 가능.
          filtered_ids = if current_user.api_level == User::ApiLevel::DASHBOARD
                           ids
                         elsif ids.include? current_user.id
                           [current_user.id]
                         else
                           []
                         end

          users = User.where(id: filtered_ids)
          return failure_response('업체를 찾을 수 없습니다.') if users.empty?

          represented = ::V1::Entities::User.represent(users)
          success_response(nil, represented.as_json)
        end
      end
    end
  end
end
