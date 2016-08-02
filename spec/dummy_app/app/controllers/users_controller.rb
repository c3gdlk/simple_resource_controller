class UsersController < ApplicationController
  resource_actions :index
  paginate_collection 2
end
