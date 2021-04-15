module V2
  module Entities
    # showing information to other users - public profile
    class OpenUserInfo < Grape::Entity
      expose :user_name, documentation: { type: 'String', desc: '사용자 이름' }
      expose :email, documentation: { type: 'String', desc: '이메일' }
      expose :created_at, documentation: { type: 'DateTime', desc: '가입 시간' }
      expose :num_of_subscribers, documentation: { type: 'Integer', desc: '구독자 수' }
    end
  end
end
