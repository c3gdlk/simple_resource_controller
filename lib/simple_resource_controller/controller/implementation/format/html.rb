module SimpleResourceController
  module Controller
    module Implementation
      module Format
        module Html
          private

          def html_before_save_success_response_callback(options)
            options[:location] ||= after_save_redirect_path
            setup_flash_messages(after_create_messages) if action_name == "create"
            setup_flash_messages(after_update_messages) if action_name == "update"
          end

          def api_before_save_failure_response_callback(options)
          end

          def html_before_destroy_response_callback(options)
            options[:location] ||= after_destroy_redirect_path
            setup_flash_messages(after_destroy_messages)
          end

          # :nocov:
          def after_save_redirect_path
            raise NotImplementedError, "Need to implement the after_save_redirect_path method"
          end
          # :nocov:

          # :nocov:
          def after_destroy_redirect_path
            raise NotImplementedError, "Need to implement the after_destroy_redirect_path method"
          end
          # :nocov:

          def after_create_messages
            after_save_messages
          end

          def after_update_messages
            after_save_messages
          end

          def after_destroy_messages
            nil
          end

          def after_save_messages
            nil
          end

          def setup_flash_messages(messages)
            return unless messages.present?

            raise 'Messages should be specified with Hash' unless messages.is_a?(Hash)

            messages.each do |key, message|
              flash[key] = message
            end
          end
        end
      end
    end
  end
end
