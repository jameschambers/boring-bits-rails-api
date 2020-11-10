Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*', 
      headers: %w(Authorization),
      expose: %w(Authorization),
      methods: :any
  end
end
