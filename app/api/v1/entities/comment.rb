module V1
  class Comment < Grape::Entity
    expose :id, documentation: { type: 'Integer', desc: '댓글 ID' }
    expose :content, documentation: { type: 'String', desc: '댓글 내용' }
    expose :user_name, documentation: { type: 'String', desc: '작성자 이름' }
    expose :post_id, documentation: { type: 'Integer', desc: '댓글이 달린 게시글의 ID'}
  end
end
