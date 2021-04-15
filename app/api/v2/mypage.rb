module V2
  class Mypage < BaseGrapeAPI
    mounted do
      before { authenticate! }
      params { requires :access_token, type: String, desc: '엑세스 토큰' }

      namespace :my_page do
        namespace :change_pw do
          desc '비밀번호 변경', entity: ::V2::Entities::SecretUserInfo
          params do
            requires :current_pw, type: String, desc: '현재 비밀번호 재확인'
            requires :new_pw, type: String, desc: '새로운 비밀번호', length: 6..20
          end
          put do
            return failure_response('비밀번호가 일치하지 않습니다.') unless current_user.valid_password?(params[:current_pw])

            current_user.update(password: params[:new_pw])
            represented = ::V2::Entities::SecretUserInfo.represent(current_user)
            success_response('비밀번호 변경에 성공했습니다.', represented.as_json)
          end
        end

        namespace :change_info do
          desc '개인정보 수정', entity: ::V2::Entities::SecretUserInfo
          params do
            optional :email, type: String, desc: '사용자 이메일', regexp: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
            optional :user_name, type: String, desc: '사용자 이름'
            optional :age, type: Integer, desc: '연령'
          end
          put do
            params.delete(:access_token)
            current_user.update(params)

            represented = ::V2::Entities::SecretUserInfo.represent(current_user)
            success_response('사용자 정보가 업데이트 되었습니다.', represented.as_json)
          end
        end

        namespace :withdraw do
          desc '회원 탈퇴'
          params { requires :password, type: String, desc: '현재 비밀번호 재확인' }
          delete do
            return failure_response('비밀번호가 일치하지 않습니다.') unless current_user.valid_password?(params[:password])

            name = current_user.user_name
            current_user.destroy
            success_response("Good bye, #{name}! We hope to meet you again!")
          end
        end
      end
    end
  end
end
