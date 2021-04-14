module V1
  module Entities
    class Category < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: '게시글 분류 ID' }
      expose :name, documentation: { type: 'String', desc: '게시글 분류' }
      expose :num_of_posts, documentation: { type: 'Integer', desc: '소속된 게시글 개수' }
    end
  end
end
