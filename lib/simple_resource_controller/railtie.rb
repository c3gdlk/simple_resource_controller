module SimpleResourceController
  require 'rails'
  require_relative './controller/config'

  class Railtie < Rails::Railtie
    initializer  'insert SimpleResourceController to ActionController' do
      ActiveSupport.on_load :action_controller do
        SimpleResourceController::Railtie.insert
      end
    end
  end

  class Railtie
    def self.insert
      if defined?(::ActionController)
        ::ActionController::Base.extend(Configurator)
        ::ActionController::Base.extend(SimpleResourceController::Controller::Config)
      end
    end
  end
end
