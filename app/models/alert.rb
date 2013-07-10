class Alert
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :server_name, type: String
  field :server_id, type: String
  field :time_stamp, type: Integer
  field :attr, type: String

  attr_accessible :server_name, :server_id, :time_stamp, :attr, :reason
end
