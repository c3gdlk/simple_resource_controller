class SomeArticlesController < ApplicationController
  resource_actions :crud
  resource_class 'Article'

  def create
    build_resource
    resource.user ||= User.create name: 'New user'

    create!
  end

  def update
    resource.user ||= User.create name: 'New user'

    create!
  end

  private

  def after_save_redirect_path
    admin_articles_path
  end
  alias :after_destroy_redirect_path :after_save_redirect_path

  def after_save_messages
    { notice: 'Saved!' }
  end

  def permitted_params
    params.require(:article).permit(:title, :user_id)
  end
end
