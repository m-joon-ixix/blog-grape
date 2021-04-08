module V1
  class Categories < BaseGrapeAPI
    mounted do
      before { authenticate! }
      params { requires :access_token, type: String, desc: '엑세스 토큰' }

      namespace :category do
        desc '전체 카테고리 목록', entity: ::V1::Entities::Category
        get do
          return failure_response('카테고리가 존재하지 않습니다.') unless Category.exists?

          represented = ::V1::Entities::Category.represent(Category.all)
          success_response(nil, represented.as_json)
        end

        desc '특정 카테고리 조회', entity: ::V1::Entities::Category
        params { requires :id, type: String, desc: '검색하려는 카테고리 ID. 콤마로 구분' }
        get ':id' do
          ids = params[:id].split(',').map(&:to_i)  # [1, 2, 3]
          categories = Category.where(id: ids)
          return failure_response('해당 카테고리를 찾을 수 없습니다.') if categories.empty?

          represented = ::V1::Entities::Category.represent(categories)
          success_response(nil, represented.as_json)
        end

        desc '카테고리 추가', entity: ::V1::Entities::Category, consumes: ['application/x-www-form-urlencoded']
        params { requires :name, type: String, desc: '추가할 카테고리 이름' }
        post do
          return failure_response('이미 존재하는 카테고리입니다.') unless Category.find_by_name(params[:name]).nil?

          category = Category.new(name: params[:name])
          return failure_response('카테고리 생성에 실패했습니다.', category.errors.messages) unless category.save

          represented = ::V1::Entities::Category.represent(category)
          success_response(nil, category.as_json)
        end
      end
    end
  end
end