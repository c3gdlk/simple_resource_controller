class PostCommentsController < BaseController
  resource_class 'Comment'
  resource_context :post, :comments, :recent
end
