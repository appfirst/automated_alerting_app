class Server
  include Mongoid::Document
  field :nickname, type: String
  field :hostname, type: String
  field :os, type: String
  field :id, type: String
  field :current_version, type: String
end
