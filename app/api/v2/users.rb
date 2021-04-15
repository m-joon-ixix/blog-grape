module V2
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
        before { authenticate! }
        params { requires :access_token, type: String, desc: '엑세스 토큰' }

        desc '현재 사용자 정보 조회 (본인 정보 조회)', entity: ::V2::Entities::SecretUserInfo
        get do
          represented = ::V2::Entities::SecretUserInfo.represent(current_user)
          success_response(nil, represented.as_json)
        end

        namespace :posts do
          desc '현재 사용자의 게시글 조회', entity: ::V1::Entities::Post
          get do
            posts = current_user.posts.order('created_at DESC')
            represented = ::V1::Entities::Post.represent(posts)
            success_response(nil, represented.as_json)
          end

          desc '현재 사용자의 게시글 전체 삭제'
          delete do
            posts = current_user.posts

            return failure_response('현재 사용자의 게시글이 존재하지 않습니다.') if posts.empty?
            # bulk-deletion 하면 연관된 comment가 destroy 되지를 않는다. 그러므로 post 하나씩 삭제.
            posts.each { |post| post.destroy }
            success_response("#{current_user.id}번 사용자의 모든 게시글을 삭제하였습니다.")
          end
        end

        resource ':user_id' do
          desc '특정 사용자 프로필 조회 (한 명)'
          get do
            user = User.find_by(id: params[:user_id])
            return failure_response('사용자를 찾을 수 없습니다.') if user.nil?

            # 여기서는 admin이라도 모든 정보까지는 열람 불가능. 본인일 때만 모든 정보 열람 가능.
            represented = if params[:user_id].to_i == current_user.id
                            ::V2::Entities::SecretUserInfo.represent(user)
                          else
                            ::V2::Entities::OpenUserInfo.represent(user)
                          end
            success_response(nil, represented.as_json)
          end

          namespace :posts do
            desc '특정 사용자의 전체 게시글 조회', entity: ::V1::Entities::Post
            get do
              return failure_response('사용자를 찾을 수 없습니다.') if User.find_by(id: params[:user_id]).nil?

              posts = Post.where(user_id: params[:user_id]).order('created_at DESC')
              represented = ::V1::Entities::Post.represent(posts)
              success_response(nil, represented.as_json)
            end
          end

        end
      end
    end
  end
end
