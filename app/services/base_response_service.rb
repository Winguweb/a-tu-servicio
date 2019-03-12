class BaseResponseService

  def initialize(branch)
    @branch = branch
    @response = _response
  end

  def self.call(branch)
    return new(branch)
  end

  attr_reader :response

  private

  def _id
    @branch.id
  end

  def _name
    @branch.name
  end

  def _address
    @branch.address
  end

  def _quality
    @branch.quality
  end

  def _waiting_times
    @branch.waiting_times
  end

  def _satisfaction
    @branch.satisfaction
  end

  def _humanization
    @branch.humanization
  end

  def _provider_name
    @branch.provider.name
  end

  def _provider_subnet
    @branch.provider.subnet
  end

  def _provider_address
    @branch.provider.address
  end

  def _provider_website
    @branch.provider.website
  end

  def _provider_communication_services
    @branch.provider.communication_services
  end

  def _response
    {
      id: _id,
      name: _name,
      address: _address,
      quality: _quality,
      waiting_times: _waiting_times,
      satisfaction: _satisfaction,
      humanization: _humanization,
      provider: {
        name: _provider_name,
        subnet: _provider_subnet,
        address: _provider_address,
        website: _provider_website,
        communication_services: _provider_communication_services
      },
    }
  end
end
