class User < ApplicationRecord
  has_many :reservations

  enum :role, admin: "admin", client: "client", default: "client"
end
