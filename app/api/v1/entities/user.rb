module V1
  class User < Grape::Entity
    expose :id, documentation: { type: 'Integer', desc: '사용자 ID' }
    expose :user_name, documentation: { type: 'String', desc: '사용자 이름' }
    expose :email, documentation: { type: 'String', desc: '이메일' }
    expose :last_sign_in_at, documentation: { type: 'DateTime', desc: '최근 접속 시간' }
  end
end
