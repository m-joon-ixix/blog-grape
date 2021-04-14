module V2
  class Posts < BaseGrapeAPI
    mounted do
      before { authenticate! }
      params { requires :access_token, type: String, desc: '엑세스 토큰' }

      namespace :post do
        desc '전체 게시글 조회', entity: ::V1::Entities::Post
        get do
          posts = Post.all.order('created_at DESC')
          represented = ::V1::Entities::Post.represent(posts)
          success_response(nil, represented.as_json)
        end

        desc '게시글 작성', entity: ::V1::Entities::Post
        params do
          requires :title, type: String, desc: '제목'
          requires :body, type: String, desc: '내용'
          requires :category_id, type: Integer, desc: '카테고리 ID'
        end
        post do
          post = Post.new(title: params[:title],
                          body: params[:body],
                          user_id: current_user.id,
                          category_id: params[:category_id])
          return failure_response('게시글 저장에 실패했습니다.') unless post.save

          represented = ::V1::Entities::Post.represent(post)
          success_response(nil, represented.as_json)
        end

        desc '특정 게시글 삭제 (본인의 게시글만 삭제 가능)'
        params { requires :post_ids, type: String, desc: '삭제할 게시글 ID들. 콤마로 구분' }
        delete do
          ids = convert_string_to_numbers(params[:post_ids])
          posts = Post.where(id: ids)
          return failure_response('해당하는 게시글이 존재하지 않습니다.') if posts.empty?

          # 여기서는 admin이라도, 본인의 게시글만 삭제할 수 있음
          posts = posts.where(user_id: current_user.id)
          return failure_response('귀하가 삭제할 수 없는 게시글입니다.') if posts.empty?

          deleted_ids = posts.pluck(:id)
          # bulk-deletion 하면 연관된 comment가 destroy 되지를 않는다. 그러므로 post 하나씩 삭제.
          posts.each { |post| post.destroy }
          success_response('삭제 완료. 삭제된 게시글 ID 번호는 다음과 같습니다.',
                           { ID: deleted_ids }.as_json )
        end

        resource ':post_id' do
          desc '특정 게시글 1개 조회', entity: ::V1::Entities::Post
          get do
            post = Post.find_by(id: params[:post_id])
            return failure_response('해당하는 게시글이 존재하지 않습니다.') if post.nil?

            represented = ::V1::Entities::Post.represent(post)
            success_response(nil, represented.as_json)
          end

          namespace :like do
            desc '게시글에 좋아요 누르기', entity: ::V2::Entities::UserLikePost
            post do
              return failure_response('해당하는 게시글이 존재하지 않습니다.') if Post.find_by(id: params[:post_id]).nil?

              like = UserLikePost.new(user_id: current_user.id, post_id: params[:post_id])
              # 저장이 안된다는 말은 즉, validation에서 uniqueness가 걸렸다는 말이다.
              return failure_response('현재 사용자는 이미 게시글에 좋아요를 눌렀습니다.') unless like.save

              represented = ::V2::Entities::UserLikePost.represent(like)
              success_response(nil, represented.as_json)
            end

            desc '게시글에서 좋아요 제거하기'
            delete do
              return failure_response('해당하는 게시글이 존재하지 않습니다.') if Post.find_by(id: params[:post_id]).nil?

              like = UserLikePost.find_by(user_id: current_user.id, post_id: params[:post_id])
              return failure_response('현재 사용자는 게시글에 좋아요를 누른 적이 없습니다.') if like.nil?

              like.destroy
              success_response("#{current_user.id}번 사용자가 #{params[:post_id]}번 게시글에서 좋아요를 삭제했습니다.")
            end
          end

          namespace :comments do
            desc '특정 게시글의 댓글 조회', entity: ::V1::Entities::Comment
            get do
              return failure_response('해당하는 게시글이 존재하지 않습니다.') if Post.find_by(id: params[:post_id]).nil?

              comments = Comment.where(post_id: params[:post_id]).order('created_at ASC')
              represented = ::V1::Entities::Comment.represent(comments)
              success_response(nil, represented.as_json)
            end
          end
        end
      end
    end
  end
end
