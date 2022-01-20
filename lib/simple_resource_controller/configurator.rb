module SimpleResourceController
  module Configurator
    def resource_actions(*args)
      SimpleResourceController::Controller.build self, args
    end
  end
end
