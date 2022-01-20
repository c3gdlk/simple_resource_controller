require_relative './controller/actions'
require_relative './controller/config'
require_relative './controller/implementation'

module SimpleResourceController
  module Controller
    DEPENDENCIES_MAP = {
      index:   Actions::Index,
      show:    Actions::Show,
      new:     Actions::New,
      create:  Actions::Create,
      edit:    Actions::Edit,
      update:  Actions::Update,
      destroy: Actions::Destroy
    }.freeze

    HELPER_METHODS = [:resource, :collection].freeze

    ALL_ACTIONS_ALIAS = :crud

    def self.build(controller_class, actions)
      unless actions.include?(ALL_ACTIONS_ALIAS)
        raise 'Unknown action name' unless (actions - DEPENDENCIES_MAP.keys).size.zero?
      end

      controller_class.extend Config

      loaded_modules = [Implementation]

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
      controller_class.respond_to :json
    end
  end
end
