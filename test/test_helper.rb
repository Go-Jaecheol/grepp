ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: 1)

    fixtures :all

    def login(user)
      post "/login", params: { name: user.name }
      response.parsed_body["token"]
    end
  end
end
