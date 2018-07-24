class CommonInfoService
  include Singleton

  def initialize
    @beds = Bed.all
    @branches = Branch.all
    @providers = Provider.all
    @satisfactions = Satisfaction.where("percentage IS NOT NULL")
    @specialities = Speciality.all

    @total_beds = _total_beds
    @total_branches = _total_branches
    @total_providers = _total_providers
    @total_satisfaction = _total_satisfaction
    @total_private_providers = _total_private_providers
    @total_public_providers = _total_public_providers
    @best_beds = _best_beds
    @best_satisfaction = _best_satisfaction
    @specialities_count_by_type = _specialities_count_by_type
    @public_specialities_count_of_type = _public_specialities_count_of_type(@specialities_count_by_type)
    @private_specialities_count_of_type = _private_specialities_count_of_type(@specialities_count_by_type)
  end

  def self.call
    return self.instance
  end

  attr_reader :total_beds, :best_beds
  attr_reader :total_branches, :total_providers
  attr_reader :total_satisfaction, :best_satisfaction
  attr_reader :total_private_providers, :total_public_providers
  attr_reader :specialities_count_by_type, :public_specialities_count_of_type, :private_specialities_count_of_type

  private

  def _best_beds
    @ordered_by_area = {}
    @beds.order(quantity: :desc).group_by(&:area).map {|area| area[1].first}.each do |bed|
      @ordered_by_area[bed.area] = bed.quantity
    end
    @ordered_by_area
  end

  def _total_branches
    @branches.count.to_i
  end

  def _total_beds
    @beds.reduce(0) {|last, bed| last += bed[:quantity]}
  end

  def _total_providers
    @providers.count.to_i
  end

  def _best_satisfaction
    @satisfactions.order(percentage: :desc).limit(1).first.percentage
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

  def _specialities_count_by_type
    @specialities.group(:name).order(:count => :desc).count.take(5).sort_by{|speciality| speciality[0]}
  end

  def _public_specialities_count_of_type(types_count)
    public_specialities = Speciality.includes(branch: [:provider]).where({:branches => {providers: {is_private: false}}})
    public_specialities.where(:name => types_count.pluck(0)).group(:name).count.sort_by{|speciality| speciality[0]}
  end

  def _private_specialities_count_of_type(types_count)
    private_specialities = Speciality.includes(branch: [:provider]).where({:branches => {providers: {is_private: true}}})
    private_specialities.where(:name => types_count.pluck(0)).group(:name).count.sort_by{|speciality| speciality[0]}
  end

end
