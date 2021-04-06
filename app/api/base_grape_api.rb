
# frozen_string_literal: true

# default grape api for mounting partials
class BaseGrapeAPI < Grape::API
  class << self
    def mountable
      Class.new(BaseGrapeAPI).tap do |klass|
        klass.instance_eval(&@proc)
      end
    end

    def mounted(&block)
      @proc = block
    end

    def mount(mt, *args)
      if mt.is_a?(Hash)
        super(mt.transform_keys { |m| m.try(:mountable) || m }, *args)
      else
        super(mt.try(:mountable) || mt, *args)
      end
    end
  end
end