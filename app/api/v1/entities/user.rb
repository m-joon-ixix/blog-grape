module V1
  module Entities
    class User < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: '사용자 ID' }
      expose :user_name, documentation: { type: 'String', desc: '사용자 이름' }
      expose :email, documentation: { type: 'String', desc: '이메일' }
      expose :api_level, documentation: { type: 'Integer', desc: '관리 권한 여부' }
    end
  end
end
