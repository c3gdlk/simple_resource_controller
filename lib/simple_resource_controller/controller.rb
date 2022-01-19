module SimpleResourceController
  module Controller
    module Index
      def index(options={}, &block)
        respond_with collection, options, &block
      end
      alias :index! :index
    end

    module Show
      def show(options={}, &block)
        respond_with resource, options, &block
      end
      alias :show! :show
    end

    module New
      def new(options={}, &block)
        build_resource
        respond_with resource, options, &block
      end
      alias :new! :new
    end

    module Create
      def create(options={}, &block)
        build_resource
        success = save_resource_and_respond!(options, &block)
        setup_flash_messages(after_create_messages) if success && !current_controller_api?
      end
      alias :create! :create
    end

    module Edit
      def edit(options={}, &block)
        respond_with resource, options, &block
      end
      alias :edit! :edit
    end

    module Update
      def update(options={}, &block)
        success = save_resource_and_respond!(options, &block)
        setup_flash_messages(after_update_messages) if success && !current_controller_api?
      end
      alias :update! :update
    end

    module Destroy
      def destroy(options={}, &block)
        destroy_resource_and_respond!(options, &block)
      ensure
        setup_flash_messages(after_destroy_messages) unless current_controller_api?
      end
      alias :destroy! :destroy
    end

    module CommonMethods
      private

      def current_controller_api?
        self.class.api_config.present?
      end

      def activemodel_serializer?
        current_controller_api? && self.class.api_config.dig(:activemodel_serializer).present?
      end

      def render_resource_with_activemodel_serializer(options)
        record_serializer = self.class.api_config.dig(:activemodel_serializer, :record_serializer)

        render({ json: resource, status: :ok }.merge(record_serializer ? { serializer: record_serializer } : {} ).merge(options))
      end

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
          raise 'Please install Kaminari' unless defined?(Kaminari)

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

        unless block_given? || options[:location].present? || current_controller_api?
          options[:location] = after_destroy_redirect_path
        end

        if activemodel_serializer?
          render_resource_with_activemodel_serializer(options)
        else
          respond_with resource, options, &block
        end
      end

      def save_resource_and_respond!(options={}, &block)
        result = resource.update(permitted_params)

        # process not saved result because of failed callback or another ActiveRecord magic
        if resource.valid? && !result.present?
          resource.errors[:base] << resource_wasnt_saved_message
        end

        if result.present?
          unless block_given? || options[:location].present? || current_controller_api?
            options[:location] = after_save_redirect_path
          end
        elsif activemodel_serializer?
          error_serializer = self.class.api_config.dig(:activemodel_serializer, :error_serializer)

          raise "error_serializer should be configured for the activemodel API" unless error_serializer.present?
          options[:serializer] = error_serializer
        end

        if result.present? && activemodel_serializer?
          render_resource_with_activemodel_serializer(options)
        else
          respond_with resource, options, &block
        end

        result
      end

      def resource_wasnt_saved_message
        raise 'Too many Rails magic. Please check your code'
      end

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

      # :nocov:
      def after_save_redirect_path
        raise 'Not Implemented'
      end
      # :nocov:

      # :nocov:
      def after_destroy_redirect_path
        raise 'Not Implemented'
      end
      # :nocov:

      # :nocov:
      def permitted_params
        raise 'Not Implemented'
      end
      # :nocov:
    end

    module Accessors
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

    class ActionsBuilder
      DEPENDENCIES_MAP = {
        index:   Index,
        show:    Show,
        new:     New,
        create:  Create,
        edit:    Edit,
        update:  Update,
        destroy: Destroy
      }.freeze

      HELPER_METHODS = [:resource, :collection].freeze

      ALL_ACTIONS_ALIAS = :crud

      def self.build(controller_class, actions)
        unless actions.include?(ALL_ACTIONS_ALIAS)
          raise 'Unknown action name' unless (actions - DEPENDENCIES_MAP.keys).size.zero?
        end

        controller_class.extend Accessors

        loaded_modules = [CommonMethods]

        if actions.include?(ALL_ACTIONS_ALIAS)
          loaded_modules += DEPENDENCIES_MAP.values
        else
          loaded_modules += actions.map { |action_name| DEPENDENCIES_MAP[action_name] }
        end

        loaded_modules.uniq.each do |loaded_module|
          controller_class.include loaded_module
        end

        HELPER_METHODS.each do |method_name|
          controller_class.helper_method method_name
        end

        controller_class.respond_to :html
      end
    end
  end
end
