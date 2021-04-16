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
          desc '카테고리 추가', entity: ::V1::Entities::Category, consumes: ['application/x-www-form-urlencoded']
          params { requires :name, type: String, desc: '추가할 카테고리 이름' }
          post do
            return failure_response('이미 존재하는 카테고리입니다.') unless Category.find_by_name(params[:name]).nil?

            category = Category.new(name: params[:name])
            return failure_response('카테고리 생성에 실패했습니다.', category.errors.messages) unless category.save

            represented = ::V1::Entities::Category.represent(category)
            success_response(nil, represented.as_json)
          end

          desc '특정 카테고리 수정', entity: ::V1::Entities::Category
          params do
            requires :category_id, type: Integer, desc: '수정하려는 카테고리 ID (1개)'
            requires :name, type: String, desc: '카테고리의 새 이름'
          end
          put do
            category = Category.find_by(id: params[:category_id])
            return failure_response('해당하는 카테고리가 존재하지 않습니다.') if category.nil?
            return failure_response('이미 존재하는 카테고리 이름입니다.') unless Category.find_by_name(params[:name]).nil?

            category.update(name: params[:name])
            represented = ::V1::Entities::Category.represent(category)
            success_response(nil, represented.as_json)
          end

          desc '특정 카테고리 삭제'
          params { requires :category_ids, type: String, desc: '삭제하려는 카테고리 ID. 콤마로 구분' }
          delete do
            ids = convert_string_to_numbers(params[:category_ids])
            categories = Category.where(id: ids)
            return failure_response('해당 카테고리가 존재하지 않습니다.') if categories.empty?

            deleted_names = categories.pluck(:name)
            # 카테고리가 삭제되기 전에 (before_destroy) callback에 걸려서 해당 게시글들의 카테고리가 '기타(0)'로 이동하도록
            categories.each { |category| category.destroy }
            success_response('삭제 완료. 삭제된 카테고리의 이름들은 다음과 같습니다.',
                             { name: deleted_names }.as_json )
          end
        end

        namespace :post do
          desc '특정 게시글 삭제 (모든 게시글 삭제 가능)'
          params { requires :post_ids, type: String, desc: '삭제할 게시글 ID들. 콤마로 구분' }
          delete do
            ids = convert_string_to_numbers(params[:post_ids])
            posts = Post.where(id: ids)
            return failure_response('해당하는 게시글이 존재하지 않습니다.') if posts.empty?

            deleted_ids = posts.pluck(:id)
            # bulk-deletion 하면 연관된 comment가 destroy 되지를 않는다. 그러므로 post 하나씩 삭제.
            posts.each { |post| post.destroy }
            success_response('삭제 완료. 삭제된 게시글 ID 번호는 다음과 같습니다.',
                             { ID: deleted_ids }.as_json )
          end
        end

        namespace :comment do
          desc '특정 댓글 삭제 (모든 댓글 삭제 가능)'
          params { requires :comment_ids, type: String, desc: '삭제할 댓글 ID들. 콤마로 구분' }
          delete do
            ids = convert_string_to_numbers(params[:comment_ids])
            comments = Comment.where(id: ids)
            return failure_response('해당하는 댓글이 존재하지 않습니다.') if comments.empty?

            deleted_ids = comments.pluck(:id)
            # bulk-deletion 하면 연관된 like가 destroy 되지를 않는다. 그러므로 comment 하나씩 삭제.
            comments.each { |comment| comment.destroy }
            success_response('삭제 완료. 삭제된 댓글 ID 번호는 다음과 같습니다.',
                             { ID: deleted_ids }.as_json )
          end
        end
      end
    end
  end
end
