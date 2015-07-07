class Metric < ActiveRecord::Base

  def for_json
    { value: value, date: created_at.to_i * 1000 }
  end

end
