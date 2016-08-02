module SimpleResourceController
  require 'rails'

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
      end
    end
  end
end
