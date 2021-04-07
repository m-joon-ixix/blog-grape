module V1
  module Entities
    class Post < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: '게시글 ID' }
      expose :title, documentation: { type: 'String', desc: '게시글 제목' }
      expose :user_name, documentation: { type: 'String', desc: '작성자 이름' }
      expose :created_at, documentation: { type: 'DateTime', desc: '게시 시간' }
    end
  end
end