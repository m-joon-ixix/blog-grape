module V2
  class Posts < BaseGrapeAPI
    mounted do
      before { authenticate! }
      params { requires :access_token, type: String, desc: '엑세스 토큰' }

      namespace :post do
        desc '전체 게시글 조회', entity: ::V1::Entities::Post
        params { optional :subscribing, type: Boolean, desc: '내가 구독중인 사용자의 게시글만 조회할 지?', default: false }
        get do
          posts = if params[:subscribing]
                    # 구독중인 사용자와 나의 게시글만 조회
                    users_that_i_subscribe = current_user.subscriptions.pluck(:subscribed_user_id)
                    users_that_i_subscribe.append(current_user.id)
                    Post.looked_by(current_user).where(user_id: users_that_i_subscribe).order('created_at DESC')
                  else
                    # 전체 게시글 조회
                    Post.looked_by(current_user).order('created_at DESC')
                  end

          represented = ::V1::Entities::Post.represent(posts)
          success_response(nil, represented.as_json)
        end

        desc '게시글 작성', entity: ::V1::Entities::Post
        params do
          requires :title, type: String, desc: '제목'
          requires :body, type: String, desc: '내용'
          requires :category_id, type: Integer, desc: '카테고리 ID'
          requires :visibility, type: String, desc: '공개 범위 (전체공개/구독자에게만/비공개)', values: Post::Visibility::ALL
        end
        post do
          params.delete(:access_token)
          post = Post.new(params)
          post.user_id = current_user.id
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

        namespace :popular do
          desc '인기 게시글 조회', entity: ::V1::Entities::Post
          get do
            # key: post_id, value: popularity of post
            post_with_popularity = Hash.new
            Post.looked_by(current_user).each do |post|
              post_with_popularity[post.id] = post.compute_popularity
            end
            # post ids with DESC-order popularity (top 10 posts)
            ordered_post_ids = post_with_popularity.sort { |a, b| b[1] <=> a[1] }
                                                   .take(10).collect(&:first)
            # posts in popularity order
            posts = Post.where(id: ordered_post_ids)
                        .order("FIELD(id, #{ordered_post_ids.join(', ')})")
            represented = ::V1::Entities::Post.represent(posts)
            success_response(nil, represented.as_json)
          end
        end

        resource ':post_id' do
          desc '특정 게시글 1개 조회', entity: ::V1::Entities::Post
          get do
            post = Post.find_by(id: params[:post_id])
            return failure_response('해당하는 게시글이 존재하지 않습니다.') if post.nil?
            return failure_response('해당 게시글 열람 권한이 없습니다.') unless post.able_to_see?(current_user.id)

            represented = ::V1::Entities::Post.represent(post)
            success_response(nil, represented.as_json)
          end

          desc '특정 게시글 수정 (본인 게시글만 수정 가능)', entity: ::V1::Entities::Post
          params do
            optional :title, type: String, desc: '제목'
            optional :body, type: String, desc: '내용'
            optional :category_id, type: Integer, desc: '카테고리 ID'
            optional :visibility, type: String, desc: '공개 범위 (전체공개/구독자에게만/비공개)', values: Post::Visibility::ALL
          end
          put do
            post = Post.find_by(id: params[:post_id])
            return failure_response('해당하는 게시글이 존재하지 않습니다.') if post.nil?
            return failure_response('해당 게시글을 수정할 권한이 없습니다.') unless post.user_id == current_user.id

            params.delete(:access_token)
            params.delete(:post_id)
            # 카테고리 변경은 반드시 이 함수를 통해 해주어야 함
            post.change_category(params[:category_id]) if params.keys.include? "category_id"
            params.delete(:category_id)

            post.update(params)
            represented = ::V1::Entities::Post.represent(post)
            success_response(nil, represented.as_json)
          end

          namespace :like do
            desc '게시글에 좋아요 누르기', entity: ::V2::Entities::UserLikePost
            post do
              post = Post.find_by(id: params[:post_id])
              return failure_response('해당하는 게시글이 존재하지 않습니다.') if post.nil?
              return failure_response('해당 게시글 열람 권한이 없습니다.') unless post.able_to_see?(current_user.id)

              like = UserLikePost.new(user_id: current_user.id, post_id: params[:post_id])
              # 저장이 안된다는 말은 즉, validation에서 uniqueness가 걸렸다는 말이다.
              return failure_response('현재 사용자는 이미 게시글에 좋아요를 눌렀습니다.') unless like.save

              represented = ::V2::Entities::UserLikePost.represent(like)
              success_response(nil, represented.as_json)
            end

            desc '게시글에서 좋아요 제거하기'
            delete do
              post = Post.find_by(id: params[:post_id])
              return failure_response('해당하는 게시글이 존재하지 않습니다.') if post.nil?
              return failure_response('해당 게시글 열람 권한이 없습니다.') unless post.able_to_see?(current_user.id)

              like = UserLikePost.find_by(user_id: current_user.id, post_id: params[:post_id])
              return failure_response('현재 사용자는 게시글에 좋아요를 누른 적이 없습니다.') if like.nil?

              like.destroy
              success_response("#{current_user.id}번 사용자가 #{params[:post_id]}번 게시글에서 좋아요를 삭제했습니다.")
            end
          end

          namespace :comments do
            desc '특정 게시글의 댓글 조회', entity: ::V1::Entities::Comment
            get do
              post = Post.find_by(id: params[:post_id])
              return failure_response('해당하는 게시글이 존재하지 않습니다.') if post.nil?
              return failure_response('해당 게시글 열람 권한이 없습니다.') unless post.able_to_see?(current_user.id)

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
