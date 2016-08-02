class RecentCommentsController < BaseController
  resource_class 'Comment'
  resource_context :article, :comments, :recent
end
