module V2
  module Entities
    # exposes all information including secret info.
    # could be accessed by admin-user, or the user himself.
    class SecretUserInfo < Grape::Entity
      expose :id, documentation: { type: 'Integer', desc: '사용자 ID' }
      expose :user_name, documentation: { type: 'String', desc: '사용자 이름' }
      expose :email, documentation: { type: 'String', desc: '이메일' }
      expose :created_at, documentation: { type: 'DateTime', desc: '가입 시간' }
      expose :num_of_subscribers, documentation: { type: 'Integer', desc: '구독자 수' }
      expose :api_level, documentation: { type: 'Integer', desc: '관리 권한 여부' }
      expose :access_token, documentation: { type: 'String', desc: '엑세스 토큰' }
    end
  end
end
