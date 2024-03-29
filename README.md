# SimpleResourceController

The simple_resource_controller gem is a lightweight analog of the good old inherited_resources. The main purpose is to save developers time for writing simple CRUD controllers.

**Important! Please remember, that this tool was created to help you and not vice versa. Do not try to fight with it. At the end, it’s just a stupid code of the stupid crud controllers.**

The main ideas
1. This gem allows you to create CRUD controller with minimum configuration
2. You do not need to cover these controllers with any tests because gem already covered well
2. It just a simple tool with a set of important configurations. It does not want to be a God tool and cover all your use cases
3. After reading this documentation you will get a clear understanding how it works under the hood.
4. The best practices guide

The last point is the most important. When a tool makes so many “magic” it should provide a best practices guide.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_resource_controller'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_resource_controller

Require it in your `config/application.rb`

```ruby
require 'simple_resource_controller'
```

## Usage

A short example

```ruby
class AnotherArticlesController < ApplicationController
  resource_actions :crud
  resource_class 'Article'
  paginate_collection 10

  private

  def after_save_redirect_path
    admin_articles_path
  end
  alias :after_destroy_redirect_path :after_save_redirect_path

  def after_save_messages
    { notice: 'Saved!' }
  end

  def permitted_params
    params.require(:article).permit(:title)
  end
end
```

### API examples

Gem suppports [jbuilder](https://github.com/rails/jbuilder) and [activemodel_serializer](https://github.com/rails-api/active_model_serializers) as API serializers

#### JBuilder

```ruby
class AnotherArticlesController < ApplicationController
  resource_actions :crud
  resource_api jbuilder: true

  private

  def permitted_params
    params.require(:article).permit(:title)
  end
end
```

But you will also need to add all view files for your actions, including `new` and `edit`.

**You can find example inside tests.**

#### ActiveModel::Serializer

Minimum config:

```ruby
class AnotherArticlesController < ApplicationController
  resource_actions :crud
  resource_api activemodel_serializer: { }

  private

  def permitted_params
    params.require(:article).permit(:title)
  end
end
```

All options:

```ruby
class AnotherArticlesController < ApplicationController
  resource_actions :crud
  resource_api activemodel_serializer: { collection_serializer: MyCollectionSerializer, resource_serializer: MyArticleSerializer, error_serializer: MyErrorSerializer }

  private

  def permitted_params
    params.require(:article).permit(:title)
  end
end
```

With redefined options:

**Important note: you should always set the error_serializer**

```ruby
class AnotherArticlesController < ApplicationController
  resource_actions :crud
  resource_api activemodel_serializer: { collection_serializer: MyCollectionSerializer, resource_serializer: MyArticleSerializer, error_serializer: MyErrorSerializer }

  # will use the AnotherArticleSerializer when success
  # will use the MyErrorSerializer when failure
  def update
    update! serializer: AnotherArticleSerializer
  end

  private

  def permitted_params
    params.require(:article).permit(:title)
  end
end
```

**You can find example inside tests.**

### Controller configuration

The first required configuration is an action name.

**Please note! The actions definition are inherited, so be careful with the base classes.**

```ruby
resource_actions :index, :show, :new, :create
resource_actions :crud # an alias for all actions
```

Other settings

```ruby
resource_class ‘User’
```

Allow specifying the model class. Will get from controller name by default.

```ruby
paginate_collection 10
```

Will use the kaminari gem for pagination. It will add `page(params[:page]).per(params[:per_page] || 10)` to your scopes.

Of course, I could make this config more flexible, but it contradicts the gem philosophy. Keep it as simple as possible. Creating controllers with that tool should be simple and new developers should not spend much time trying to understand what all these configs mean.

```ruby
resource_context :current_user
```

The last and more complex setting is the `resource_context`. Please avoid it if it isn’t clear to you how it works inside.

But before describing it I would like to talk about some issues of the inherited_resources gem. The Inherited resources was one of my favorite gems for a long time. But when my team grows I got that for Rails newcomers is so hard to dive in code written with it. Hard to understand what all these `begin_of_association_chain`, `end_of_association_chain` and the other methods do. How to combine them together and use it properly. At the end it’s just a stupid CRUD controller, developers should not spend much time to figure out how it works. But this is the issue both gems are trying to solve - do not spend any time on simple things.

So, let's back to the `resource_context` option. It the most “magic” config, but it has only two possible usages.

1. There is a single parameter. In that case, the method with parameter name be the base and gem will build the relation from the controller name
2. There are several parameters. In this case, it also uses the method with parameter name as a base. But there is no any additional magic here. All next params will specify the chain (In the first case it was defined by controller name)

It’s hard to get it from the description, but the examples below are pretty clear. Please note, that the commented part is the code generated by the gem.

```ruby
class ArticlesController < ApplicationController
  resource_actions :index

  #def index
    #@articles = Article.all
  #end
end
```
```ruby
class ArticlesController < ApplicationController
  resource_actions :index
  resource_context :current_user

  # current_user - from params
  # .articles - from controller name
  #def index
    #@articles = current_user.articles
  #end
end
```
```ruby
class ArticlesController < ApplicationController
  resource_actions :index
  resource_context :current_user, :articles, :recent

  # no magic with controller name, explicit chain
  #def index
    #@articles = current_user.articles.recent
  #end
end
```
```ruby
class ArticlesController < ApplicationController
  resource_actions :index
  resource_context :category, :articles

  #def index
    #@articles = category.articles
  #end

  private

  def category
    current_user.categories.find(params[:category_id])
  end
end
```

If the method doesn’t exist it could try to generate it by supposing that this is a case of the nested resources.

```ruby
class ArticlesController < ApplicationController
  resource_actions :index
  resource_context :category, :articles

  #def index
    #@articles = Category.find(params[:category_id]).articles
  #end
end
```

The last example details

```ruby
class ArticlesController < ApplicationController
  resource_actions :index
  resource_context :category, :articles
  #def index
    #@articles = Category.find(params[:category_id]).articles
  #end
end
```

Because the `ArticlesController` doesn’t define a `def category; end` method gem will try to build the class name and find the record by `params[:category_id]`
`

The has_scope gem also will automatically work if any scopes specified.

```ruby
class ArticlesController < ApplicationController
  resource_actions :index
  resource_context :category, :articles
  paginage_collection 10
  has_scope :recent, type: :boolean
  #def index
    #@articles = apply_scopes(Category.find(params[:category_id]).articles).page(params[:page]).per(params[:per_page] || per_page)
  #end
end
```

That's all. There are no other available settings. Really simple, isn’t it?

### The template methods

Gem was developed with the Template pattern, so there are a few methods you can override your needs.

#### The required overrides.

You need to define next methods only if you use related actions
```ruby
def after_save_redirect_path
  raise 'Not Implemented'
end

def after_destroy_redirect_path
  raise 'Not Implemented'
end

def permitted_params
  raise 'Not Implemented'
end
```

#### Flash messages

By default there are no any messages

```ruby
def after_create_messages
  after_save_messages
end

def after_update_messages
  after_save_messages
end

def after_destroy_messages
  nil
end

def after_save_messages
  nil
end
```

You can define any of these methods, They should return a Hash with types and messages

```ruby
def after_destroy_messages
  { success: 'Record was successfully deleted' }
end
```

#### Fetch data methods

If the `resource_context` is not enough or you find it too complex, just redefine the basic methods `collection` and `resource`. Both already defined as helper methods and could be used inside views. Don’t forget about the memoization.

```ruby
def resource
  @article ||= Article.find(params[:id])
end

def collection
  @articles ||= Article.all
end
```

#### Controller actions

Gem based on the responders one, so you can easy redefine the basic methods. It has the same interface as the inherited_resources.

```ruby
class ArticlesController < ApplicationController
  resource_actions :update

  def update
    @article = Article.find(params[:id])
    @article.category = Category.find(params[:category_id])

    update!
  end
end
```
```ruby
class ArticlesController < ApplicationController
  resource_actions :update

  def update
    update! do |format|
      unless resource.errors.empty? # failure
        format.html { redirect_to project_url(resource) }
      end
    end
  end
end
```
```ruby
class ArticlesController < ApplicationController
  resource_actions :update

  def update
    update! do |success, failure|
      failure.html { redirect_to project_url(resourcet) }
    end
  end
end
```

#### A bit more about flashes and redirects

Instead of

```ruby
class ArticlesController < ApplicationController
  resource_actions :create
  private
  def after_create_messages
    {notice: ‘Some message’}
  end
 end
```

You can write

```ruby
class ArticlesController < ApplicationController

  resource_actions :create

  def create
    create! notice: ‘Some message’
  end
end
```

The second example looks more elegant, but it’s much easy to write tests for the first one. Because for the first example you just need to ensure that the `after_create_messages` return a correct hash. But for the second one, you will need to write a test for the `create` method from scratch because you redefine it and can’t rely on the gem tests.

### Possible issues

I’ve used a contract development to raise exceptions if something configured wrong. Please check the exceptions below you can get.

#### `Not Implemented`

You didn’t define the template methods. Please check the documentation above.

#### `Messages should be specified with Hash`

Flash messages should be configured as a hash

#### `Please install Kaminari`

You are trying to use pagination but gem kaminary is missing

#### `#{context} hasn't relation #{scope}`

Wrong usage of the `resource_context`. Please remember that there is only single parameter it will build the second one from the controller name

```ruby
class ArticlesController < ApplicationController
  resource_actions :index
  resource_context :current_user

  #def index
    #@articles = current_user.articles
  #end
end
```

So, the  User model should have `has_many : articles` relation

#### `Undefined context method #{context_method}`

Wrong usage of the `resource_context`.  If there is no method with the same name or relevant param - it will cause that exception. Please check the documentation about `resource_context`

#### `Could not find model #{class_name} by param #{context_method}_id`

The similar exception to the previous one, but in that case, there is a relevant parameter, but there is no a Rails model with relevant name.

```ruby
class ArticlesController < ApplicationController
  resource_actions :index
  resource_context :category, :articles

  #def index
    #@articles = Category.find(params[:category_id]).articles
  #end
end
```

You will get this exception if the Category model is missing.


#### ```Too many Rails magic. Please check your code```

This is my favorite one. The `responders` gem follows the next logic - if a record is valid it means that it was saved to the database. But there is a case when too many Rails magic can cause valid records which weren’t saved to the DB. Yeah, sometimes Rails hurts =)
If you will get this exception - check your ActiveRecord callbacks, your code has some smells.


#### `error_serializer should be configured for the activemodel API`

You are trying to use the `resource_api` DSL to setup the activemodel_serializer, faced with the validation error in create or update action.
But didn't configured an error serializer: `resource_api activemodel_serializer: { error_serializer: MyErrorSerializer }`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/c3gdlk/simple_resource_controller. This project is intended to be a safe, welcoming space for collaboration.

Not work for now =((
```
bundle exec mutant --include lib --require simple_resource_controller --use rspec "SimpleResourceController*"
```


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
