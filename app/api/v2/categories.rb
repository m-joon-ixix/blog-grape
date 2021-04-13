module V2
  class Categories < BaseGrapeAPI
    mounted do
      before { authenticate! }
      params { requires :access_token, type: String, desc: '엑세스 토큰' }

      namespace :category do
        desc '전체 카테고리 목록', entity: ::V1::Entities::Category
        get do
          represented = ::V1::Entities::Category.represent(Category.all)
          success_response(nil, represented.as_json)
        end

        namespace :posts do
          desc '특정 카테고리들의 게시글 조회', entity: ::V1::Entities::Post
          params { requires :category_ids, type: String, desc: '검색하려는 카테고리 ID. 콤마로 구분' }
          get do
            ids = convert_string_to_numbers(params[:category_ids])
            return failure_response('해당 카테고리는 존재하지 않습니다.') if Category.where(id: ids).empty?

            posts = Post.where(category_id: ids).order('created_at DESC')
            represented = ::V1::Entities::Post.represent(posts)
            success_response(nil, represented.as_json)
          end
        end
      end
    end
  end
end
