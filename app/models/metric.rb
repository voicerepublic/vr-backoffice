class Metric < ActiveRecord::Base

  def for_json
    { value: value, date: created_at.to_i }
  end

end
