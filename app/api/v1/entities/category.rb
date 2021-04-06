module V1
  class Category < Grape::Entity
    expose :id, documentation: { type: 'Integer', desc: '게시글 분류 ID' }
    expose :name, documentation: { type: 'String', desc: '게시글 분류' }
  end
end
