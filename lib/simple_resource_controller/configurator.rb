module SimpleResourceController
  module Configurator
    def resource_actions(*args)
      SimpleResourceController::Controller::ActionsBuilder.build self, args
    end
  end
end
