class DistrictCode < ApplicationRecord
  default_scope -> { order(place: :asc) }
  
  def district_with_code
    "#{self.place} (#{self.code})"
  end
  
end
