class BaseController < ApplicationController
  resource_actions :index, :new, :create, :edit, :update, :destroy
end
