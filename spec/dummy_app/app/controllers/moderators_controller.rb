class ModeratorsController < ApplicationController
  resource_actions :index
  resource_class 'User'
end
