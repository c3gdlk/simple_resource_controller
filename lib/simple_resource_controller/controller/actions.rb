module SimpleResourceController
  module Controller
    module Actions
      module Index
        def index(options={}, &block)
          unless block_given?
            if current_controller_api?
              api_before_index_response_callback(options)
            else
              html_before_index_response_callback(options)
            end
          end

          respond_with collection, options, &block
        end
        alias :index! :index
      end

      module Show
        def show(options={}, &block)
          unless block_given?
            if current_controller_api?
              api_before_show_response_callback(options)
            else
              html_before_show_response_callback(options)
            end
          end

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
          save_resource_and_respond!(options, &block)
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
          save_resource_and_respond!(options, &block)
        end
        alias :update! :update
      end

      module Destroy
        def destroy(options={}, &block)
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
        alias :destroy! :destroy
      end
    end
  end
end
