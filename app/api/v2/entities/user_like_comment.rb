module V2
  module Entities
    class UserLikeComment < Grape::Entity
      expose :comment_id, documentation: { type: 'Integer', desc: '좋아요 누른 댓글 ID' }
      expose :post_id_of_comment, documentation: { type: 'Integer', desc: '댓글이 속한 게시글 ID' }
      expose :user_id, documentation: { type: 'Integer', desc: '좋아요 누른 사용자 ID' }
      expose :user_name, documentation: { type: 'String', desc: '좋아요 누른 사용자 이름' }
    end
  end
end
