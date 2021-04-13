module V1
  class Users < BaseGrapeAPI
    mounted do
      # authentication 전에 회원가입하는 API
      namespace :signup do
        desc '회원가입 (사용자 추가)', entity: ::V1::Entities::User
        params do
          requires :email, type: String, desc: '사용자 이메일', regexp: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
          requires :password, type: String, desc: '비밀번호', length: 6..20
          optional :user_name, type: String, desc: '사용자 이름'
          optional :age, type: Integer, desc: '연령'
        end
        post do
          full_params = declared(params)  # including every optional but not assigned params
          user = User.new(full_params)
          return failure_response('사용자 등록에 실패했습니다.', user.errors) unless user.save

          represented = ::V1::Entities::User.represent(user)
          success_response(nil, represented.as_json)
        end
      end

      namespace :user do
        # need to be authenticated to continue from here
        before { authenticate! }
        params { requires :access_token, type: String, desc: '엑세스 토큰' }

        desc '현재 사용자 조회', entity: ::V1::Entities::User
        get do
          represented = ::V1::Entities::User.represent(current_user)
          success_response(nil, represented.as_json)
        end

        namespace :posts do
          desc '현재 사용자의 게시글 조회', entity: ::V1::Entities::Post
          get do
            posts = Post.where(user_id: current_user.id)
            represented = ::V1::Entities::Post.represent(posts)
            success_response(nil, represented.as_json)
          end
        end

        params { requires :id, type: String, desc: '검색할 사용자 ID. 콤마로 구분' }
        resource ':id' do
          desc '특정 사용자 조회', entity: ::V1::Entities::User
          get do
            ids = params[:id].split(',').map(&:to_i)
            # DASHBOARD인 유저는 모든 검색 가능. 그렇지 않으면 본인만 검색 가능.
            filtered_ids = if current_user.is_admin?
                             ids
                           elsif ids.include? current_user.id
                             [current_user.id]
                           else
                             []
                           end

            users = User.where(id: filtered_ids)
            return failure_response('사용자를 찾을 수 없습니다.') if users.empty?

            represented = ::V1::Entities::User.represent(users)
            success_response(nil, represented.as_json)
          end

          desc '특정 사용자 삭제 (관리자만 가능)'
          delete do
            return failure_response('사용자를 삭제할 권한이 없습니다.') unless current_user.is_admin?

            ids = params[:id].split(',').map(&:to_i)
            users = User.where(id: ids)
            return failure_response('사용자를 찾을 수 없습니다.') if users.empty?

            deleted_names = users.pluck(:email)
            # 삭제되는 user와 연관된 post, comment가 모두 destroy 될 수 있도록 bulk-deletion은 하지 않는다.
            users.each { |user| user.destroy }
            success_response('사용자 삭제 완료. 삭제된 사용자들의 이메일은 다음과 같습니다.',
                             { email: deleted_names }.as_json)
          end

          namespace :control_api_level do
            desc '특정 사용자에게 관리자 권한 (DASHBOARD api_level) 부여 또는 박탈', entity: ::V1::Entities::User
            params { requires :dashboard, type: Boolean, desc: '관리자 권한 부여 여부 (True/False)'}
            put do
              return failure_response('권한이 없습니다.') unless current_user.is_admin?

              ids = params[:id].split(',').map(&:to_i)
              users = User.where(id: ids)
              return failure_response('사용자를 찾을 수 없습니다.') if users.empty?

              api_level = params[:dashboard] ? User::ApiLevel::DASHBOARD : User::ApiLevel::DEFAULT
              users.each { |user| user.update(api_level: api_level) }

              represented = ::V1::Entities::User.represent(users)
              success_response('다음 사용자들의 관리자 권한이 업데이트 되었습니다.', represented.as_json)
            end
          end
        end
      end
    end
  end
end
