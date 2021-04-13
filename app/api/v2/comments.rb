module V2
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

          return failure_response('댓글 저장에 실패했습니다.', comment.errors) unless comment.save
          represented = ::V1::Entities::Comment.represent(comment)
          success_response(nil, represented.as_json)
        end

        desc '특정 댓글 삭제 (본인의 댓글 또는 본인의 게시글에 달린 댓글만 삭제 가능)'
        params { requires :comment_ids, type: String, desc: '삭제할 댓글 ID들. 콤마로 구분' }
        delete do
          ids = convert_string_to_numbers(params[:comment_ids])
          comments = Comment.where(id: ids)
          return failure_response('해당하는 댓글이 존재하지 않습니다.') if comments.empty?

          # 여기서는 admin이라도 남의 댓글을 삭제할 수는 없음. 게시글 작성자 또는 댓글 작성자만 삭제 권한이 있음
          comments = comments.able_to_delete(current_user.id)
          return failure_response('이 댓글들을 삭제할 권한이 없습니다.') if comments.empty?

          deleted_ids = comments.pluck(:id)
          # 연관된 기록들 (좋아요, 게시글의 댓글 수) 반영을 위해 bulk-deletion 자제
          comments.each { |comment| comment.destroy }
          success_response('삭제 완료. 삭제된 댓글들의 ID 번호는 다음과 같습니다.',
                           { id: deleted_ids }.as_json)
        end

        resource ':comment_id' do
          desc '특정 댓글 1개 조회', entity: ::V1::Entities::Comment
          get do
            comment = Comment.find_by(id: params[:comment_id])

            return failure_response('해당하는 댓글이 존재하지 않습니다.') if comment.nil?
            represented = ::V1::Entities::Comment.represent(comment)
            success_response(nil, represented.as_json)
          end
        end
      end
    end
  end
end
