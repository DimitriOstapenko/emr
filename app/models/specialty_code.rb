class SpecialtyCode < ApplicationRecord
  default_scope -> { order(code: :asc) }
  
  def specialty_with_code
    "#{self.description} (#{self.code})"
  end

end
