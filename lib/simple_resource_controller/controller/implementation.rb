require_relative './implementation/format/api'
require_relative './implementation/format/html'

module SimpleResourceController
  module Controller
    module Implementation
      include Format::Api
      include Format::Html

      private

      def collection
        return instance_variable_get(:"@#{collection_name}") if instance_variable_get(:"@#{collection_name}").present?
        instance_variable_set(:"@#{collection_name}", apply_scopes_and_pagination(association_chain))
      end

      def apply_scopes_and_pagination(chain)
        if respond_to?(:apply_scopes, true)
          chain = apply_scopes(chain)
        end

        per_page = self.class.paginate_collection_config

        if per_page.present?
          raise 'Please install Kaminari' unless defined?(::Kaminari)

          chain = chain.page(params[:page]).per(params[:per_page] || per_page)
        else
          chain = chain.all
        end

        chain
      end

      def collection_name
        resource_name.pluralize
      end

      def resource_class_name
        self.class.resource_class_config || self.class.name.split('::').last.gsub('Controller', '').singularize
      end

      def resource_class
        resource_class_name.constantize
      end

      def resource_name
        resource_class_name.split('::').last.underscore
      end

      def resource_relation_name
        resource_class_name.underscore.pluralize
      end

      def association_chain
        self.class.resource_context_config.present? ? association_chain_by_context : resource_class
      end

      def association_chain_by_context
        specified_scopes.reduce(default_context) do |context, scope|
          raise "#{context.inspect} hasn't relation #{scope}" unless context.respond_to? scope

          context.public_send(scope)
        end
      end

      def default_context
        context_method = self.class.resource_context_config.first

        if self.respond_to? context_method, true
          context = send(context_method)
        elsif params["#{context_method}_id"].present?
          class_name = context_method.to_s.classify
          context_class = class_name.safe_constantize

          if context_class.present?
            context = context_class.find(params["#{context_method}_id"])
          else
            raise "Could not find model #{class_name} by param #{context_method}_id"
          end
        else
          raise "Undefined context method #{context_method}"
        end

        context
      end

      def specified_scopes
        if self.class.resource_context_config.size > 1
          self.class.resource_context_config[1..-1]
        else
          [resource_relation_name.to_sym]
        end
      end

      def build_resource
        return instance_variable_get(:"@#{resource_name}") if instance_variable_get(:"@#{resource_name}").present?

        new_instance = association_chain.is_a?(ActiveRecord::Relation) ? association_chain.build : association_chain.new
        instance_variable_set(:"@#{resource_name}", new_instance)
      end

      def resource
        return instance_variable_get(:"@#{resource_name}") if instance_variable_get(:"@#{resource_name}").present?
        instance_variable_set(:"@#{resource_name}",  association_chain.find(params[:id]))
      end

      def destroy_resource_and_respond!(options={}, &block)
        resource.destroy

        unless block_given?
          if current_controller_api?
            api_before_destroy_response_callback(options)
          else
            html_before_destroy_response_callback(options)
          end
        end

        respond_with resource, options, &block
      end

      def save_resource_and_respond!(options={}, &block)
        success = resource.update(permitted_params)

        # process not saved result because of failed callback or another ActiveRecord magic
        if resource.valid? && !success
          resource.errors[:base] << resource_wasnt_saved_message
        end

        unless block_given?
          if success
            if current_controller_api?
              api_before_save_success_response_callback(options)
            else
              html_before_save_success_response_callback(options)
            end
          else
            if current_controller_api?
              api_before_save_failure_response_callback(options)
            else
              api_before_save_failure_response_callback(options)
            end
          end
        end

        respond_with resource, options, &block
      end

      def resource_wasnt_saved_message
        raise 'Too many Rails magic. Please check your code'
      end

      # :nocov:
      def permitted_params
        raise NotImplementedError, "Need to implement the permitted_params method"
      end
      # :nocov:
    end
  end
end
