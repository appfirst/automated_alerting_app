class Request
  include Mongoid::Document
  field :server_name, type: Sring
  field :server_id, type: String
  field :attr_name, type: String
end
