Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"   # tighten to your frontend domain in production

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose:  %w[Authorization]
  end
end
