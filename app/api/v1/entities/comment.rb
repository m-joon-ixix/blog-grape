module V1
  module Entities
    class Comment < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: '댓글 ID' }
      expose :content, documentation: { type: 'String', desc: '댓글 내용' }
      expose :user_name, documentation: { type: 'String', desc: '작성자 이름' }
      expose :post_id, documentation: { type: 'Integer', desc: '댓글이 달린 게시글의 ID'}
      expose :num_of_likes, documentation: { type: 'Integer', desc: '좋아요 개수' }
    end
  end
end
