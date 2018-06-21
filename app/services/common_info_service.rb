class CommonInfoService
  include Singleton

  def initialize
    @branches = Branch.all
    @providers = Provider.all
    @satisfactions = Satisfaction.all

    @total_branches = _total_branches
    @total_providers = _total_providers
    @total_satisfaction = _total_satisfaction
    @total_private_providers = _total_private_providers
    @total_public_providers = _total_public_providers
  end

  def self.call
    return self.instance
  end

  attr_reader :total_branches, :total_providers, :total_satisfaction, :total_private_providers, :total_public_providers

  private

  def _total_branches
    @branches.count.to_i
  end

  def _total_providers
    @providers.count.to_i
  end

  def _total_satisfaction
    (@satisfactions.sum(:percentage) / @total_providers).to_f
  end

  def _total_private_providers
    @providers.where(:is_private => true).count.to_i
  end

  def _total_public_providers
    @providers.where(:is_private => false).count.to_i
  end

end
