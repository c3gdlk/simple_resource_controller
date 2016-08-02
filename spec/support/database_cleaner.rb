RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:active_record].clean_with :truncation
  end

  config.before(:each) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:active_record].start
  end

  config.after(:each) do
    DatabaseCleaner[:active_record].clean
  end
end
