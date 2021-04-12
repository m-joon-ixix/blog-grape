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

        desc '신규 사용자 추가 (관리자만 가능)', entity: ::V1::Entities::User
        params do
          requires :email, type: String, desc: '사용자 이메일'
          requires :password, type: String, desc: '비밀번호'
          optional :user_name, type: String, desc: '사용자 이름'
          optional :age, type: Integer, desc: '연령'
          optional :api_level, type: Integer, desc: '접근권한 (0 또는 1)'
        end
        post do
          return failure_response('사용자를 등록할 권한이 없습니다.') unless current_user.is_admin?

          full_params = declared(params)  # including every optional but not assigned params
          full_params.delete(:access_token)  # don't put in the current_user's access_token
          user = User.new(full_params)
          return failure_response('사용자 등록에 실패했습니다.') unless user.save

          represented = ::V1::Entities::User.represent(user)
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
        end
      end
    end
  end
end
