module V1
  class Base < ::BaseGrapeAPI
    mounted do
      version 'v1', using: :path

      mount ::V1::Users
      mount ::V1::Categories
      mount ::V1::Posts
      mount ::V1::Comments

      add_swagger_documentation mount_path: 'docs',
                                api_version: 'v1',
                                doc_version: '1.0.0',
                                info: {
                                  title: 'Blog API',
                                  description: 'Grape API 연습을 위한 블로그 운영 API 명세',
                                  contact_name: '최민준',
                                  contact_email: 'miles@dunamu.com'
                                }
    end
  end
end