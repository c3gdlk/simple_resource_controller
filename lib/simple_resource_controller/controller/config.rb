module SimpleResourceController
  module Controller
    module Config
      def resource_class_config
        @resource_class_config
      end

      def resource_class(value)
        @resource_class_config = value
      end

      def resource_context_config
        @resource_context_config
      end

      def resource_context(*values)
        @resource_context_config = values
      end

      def paginate_collection_config
        @paginate_collection_config
      end

      def paginate_collection(value)
        @paginate_collection_config = value
      end

      def api_config
        @api_config
      end

      def resource_api(value)
        @api_config = value
      end
    end
  end
end
