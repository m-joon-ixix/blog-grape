module V1
  class Posts < BaseGrapeAPI
    mounted do
      before { authenticate! }
      params { requires :access_token, type: String, desc: '엑세스 토큰' }

      namespace :post do
        desc '전체 게시글 조회', entity: ::V1::Entities::Post
        get do
          posts = Post.all
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

        desc '현재 사용자의 게시글 전체 삭제'
        delete do
          posts = Post.where(user_id: current_user.id)

          return failure_response('현재 사용자의 게시글이 존재하지 않습니다.') if posts.empty?
          # hook for bulk-deletion
          posts.each { |post| post.decrement_num_of_posts }
          success_response("#{current_user.id}번 사용자의 모든 게시글을 삭제하였습니다.") if posts.delete_all
        end

        params { requires :id, type: String, desc: '검색할 게시글 ID. 콤마로 구분' }
        resource ':id' do
          desc '특정 게시글 조회', entity: ::V1::Entities::Post
          get do
            ids = params[:id].split(',').map(&:to_i)
            posts = Post.where(id: ids)

            return failure_response('해당하는 게시글이 존재하지 않습니다.') if posts.empty?

            represented = ::V1::Entities::Post.represent(posts)
            success_response(nil, represented.as_json)
          end

          desc '특정 게시글 삭제'
          delete do
            ids = params[:id].split(',').map(&:to_i)
            posts = Post.where(id: ids)
            return failure_response('해당하는 게시글이 존재하지 않습니다.') if posts.empty?

            posts = posts.where(user_id: current_user.id)
            return failure_response('귀하가 삭제할 수 없는 게시글입니다.') if posts.empty?

            deleted_ids = posts.pluck(:id)
            # make sure the hook is considered (before bulk-deletion)
            posts.each { |post| post.decrement_num_of_posts }
            posts.delete_all
            success_response('삭제 완료. 삭제된 게시글 ID 번호는 다음과 같습니다.',
                             { ID: deleted_ids }.as_json )
          end

          namespace :comments do
            desc '특정 게시글들의 댓글 조회', entity: ::V1::Entities::Comment
            get do
              ids = params[:id].split(',').map(&:to_i)

              return failure_response('해당하는 게시글이 존재하지 않습니다.') if Post.where(id: ids).empty?
              comments = Comment.where(post_id: ids)
              represented = ::V1::Entities::Comment.represent(comments)
              success_response(nil, represented.as_json)
            end
          end
        end
      end
    end
  end
end