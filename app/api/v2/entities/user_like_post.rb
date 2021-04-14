module V2
  module Entities
    class UserLikePost < Grape::Entity
      expose :post_id, documentation: { type: 'Integer', desc: '좋아요 누른 게시글 ID' }
      expose :post_title, documentation: { type: 'String', desc: '좋아요 누른 게시글 제목' }
      expose :user_id, documentation: { type: 'Integer', desc: '좋아요 누른 사용자 ID' }
      expose :user_name, documentation: { type: 'String', desc: '좋아요 누른 사용자 이름' }
    end
  end
end
