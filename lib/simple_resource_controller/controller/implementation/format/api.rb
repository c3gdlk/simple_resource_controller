module SimpleResourceController
  module Controller
    module Implementation
      module Format
        module Api
          private

          def api_before_save_success_response_callback(options)
            options[:status] ||= :created if action_name == "create"

            if activemodel_serializer?
              record_serializer = self.class.api_config.dig(:activemodel_serializer, :record_serializer)
              options[:json] ||= resource
              options[:serializer] ||= record_serializer
            end
          end

          def api_before_save_failure_response_callback(options)
            if activemodel_serializer?
              error_serializer = self.class.api_config.dig(:activemodel_serializer, :error_serializer)

              raise "error_serializer should be configured for the activemodel API" unless error_serializer.present?
              options[:json] ||= resource
              options[:serializer] = error_serializer
            end
          end

          def api_before_destroy_response_callback(options)
            if activemodel_serializer?
              record_serializer = self.class.api_config.dig(:activemodel_serializer, :record_serializer)
              options[:json] ||= resource
              options[:serializer] ||= record_serializer
            end
          end

          def current_controller_api?
            self.class.api_config.present?
          end

          def activemodel_serializer?
            current_controller_api? && self.class.api_config.dig(:activemodel_serializer).present?
          end
        end
      end
    end
  end
end
