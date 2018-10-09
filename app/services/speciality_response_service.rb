class SpecialityResponseService
  include Singleton

  def initialize(branch)
    @branch = branch
    @response = _response
  end

  def self.call(branch)
    return new(branch)
  end

  attr_reader :response

  private

  def _specialities
    @specialities.map do |speciality|
      _speciality(speciality)
    end
  end

  def _specialities_count
    @specialities.count
  end

  def _speciality(speciality)
    { name: speciality.name }
  end

  def _response
    @specialities = @branch.specialities
    {
      specialities: _specialities,
      specialities_count: _specialities_count
    }
  end
end
