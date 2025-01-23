class User < ApplicationRecord
  enum :role, admin: "admin", client: "client", default: "client", null: false
end
