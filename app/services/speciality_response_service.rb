class SpecialityResponseService
  include Singleton

  def initialize(branch)
    @branch = branch
    @specialities = @branch.specialities
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
    {
      initial_source: {
        specialities: _specialities,
        specialities_count: _specialities_count
      },
      surveys_source: {
        specialities: _specialities,
        specialities_count: _specialities_count
      }
    }
  end
end
