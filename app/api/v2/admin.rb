module V2
  class Admin < BaseGrapeAPI
    mounted do
      before { admin_check! }
      params { requires :access_token, type: String, desc: '엑세스 토큰' }

      namespace :admin do
        namespace :user do
          desc '사용자 조회', entity: ::V2::Entities::SecretUserInfo
          params { requires :user_ids, type: String, desc: '검색할 사용자 ID. 콤마로 구분' }
          get do
            ids = convert_string_to_numbers(params[:user_ids])
            users = User.where(id: ids)
            return failure_response('사용자를 찾을 수 없습니다.') if users.empty?

            represented = ::V2::Entities::SecretUserInfo.represent(users)
            success_response(nil, represented.as_json)
          end

          desc '사용자 삭제 (강제 탈퇴)'
          params { requires :user_ids, type: String, desc: '삭제할 사용자 ID. 콤마로 구분' }
          delete do
            ids = convert_string_to_numbers(params[:user_ids])
            users = User.where(id: ids)
            return failure_response('사용자를 찾을 수 없습니다.') if users.empty?

            deleted_names = users.pluck(:email)
            # 삭제되는 user와 연관된 post, comment가 모두 destroy 될 수 있도록 bulk-deletion은 하지 않는다.
            users.each { |user| user.destroy }
            success_response('사용자 삭제 완료. 삭제된 사용자들의 이메일은 다음과 같습니다.',
                             { email: deleted_names }.as_json)
          end

          namespace :control_api_level do
            desc '특정 사용자에게 관리자 권한 (DASHBOARD api_level) 부여 또는 박탈', entity: ::V2::Entities::SecretUserInfo
            params do
              requires :dashboard, type: Boolean, desc: '관리자 권한 부여 여부 (True/False)'
              requires :user_ids, type: String, desc: '권한을 변경할 사용자 ID. 콤마로 구분'
            end
            put do
              ids = convert_string_to_numbers(params[:user_ids])
              users = User.where(id: ids)
              return failure_response('사용자를 찾을 수 없습니다.') if users.empty?

              api_level = params[:dashboard] ? User::ApiLevel::DASHBOARD : User::ApiLevel::DEFAULT
              users.each { |user| user.update(api_level: api_level) }

              represented = ::V2::Entities::SecretUserInfo.represent(users)
              success_response('다음 사용자들의 관리자 권한이 업데이트 되었습니다.', represented.as_json)
            end
          end
        end

        namespace :category do

        end

        namespace :post do

        end

        namespace :comment do

        end
      end
    end
  end
end
