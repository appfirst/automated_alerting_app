class Alert
  include Mongoid::Document
  field :server_name, type: String
  field :server_id, type: String
  field :time_stamp, type: String
  field :attr, type: String
  field :reason, type: String

  attr_accessible :server_name, :server_id, :time_stamp, :attr, :reason
end
