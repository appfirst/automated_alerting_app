class Request
  include Mongoid::Document
  field :server_name, type: String
  field :server_id, type: String
  field :attr_name, type: String
  field :running, type: Boolean, default: false

  attr_accessible :server_name, :server_id, :attr_name, :running

end
