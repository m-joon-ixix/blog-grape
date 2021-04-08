module V1
  class Comments < BaseGrapeAPI
    mounted do
      before { authenticate! }
      params { requires :access_token, type: String, desc: '엑세스 토큰' }

      namespace :comment do
        desc '댓글 작성', entity: ::V1::Entities::Comment
        params do
          requires :content, type: String, desc: '내용'
          requires :post_id, type: Integer, desc: '게시글 ID'
        end
        post do
          comment = Comment.new(content: params[:content],
                          user_id: current_user.id,
                          post_id: params[:post_id])

          return failure_response('댓글 저장에 실패했습니다.') unless comment.save
          represented = ::V1::Entities::Comment.represent(comment)
          success_response(nil, represented.as_json)
        end

        params { requires :id, type: String, desc: '댓글 ID. 콤마로 구분' }
        resource ':id' do
          desc '특정 댓글 조회', entity: ::V1::Entities::Comment
          get do
            ids = params[:id].split(',').map(&:to_i)
            comments = Comment.where(id: ids)

            return failure_response('해당하는 댓글이 존재하지 않습니다.') if comments.empty?
            represented = ::V1::Entities::Comment.represent(comments)
            success_response(nil, represented.as_json)
          end

        end
      end
    end
  end
end
