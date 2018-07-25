class CommonInfoService
  include Singleton

  def initialize
    @beds = Bed.all
    @branches = Branch.all
    @providers = Provider.all
    @satisfactions = Satisfaction.where("percentage IS NOT NULL")
    @specialities = Speciality.all
    @waiting_times = WaitingTime.all

    @total_beds = _total_beds
    @total_branches = _total_branches
    @total_providers = _total_providers
    @total_satisfaction = _total_satisfaction
    @total_private_providers = _total_private_providers
    @total_public_providers = _total_public_providers
    @best_beds = _best_beds
    @best_satisfaction = _best_satisfaction
    @best_waiting_times = _best_waiting_times
    @worst_total_waiting_times = _worst_total_waiting_times
    @specialities_count_by_type = _specialities_count_by_type
    @public_specialities_count_of_type = _public_specialities_count_of_type(@specialities_count_by_type)
    @private_specialities_count_of_type = _private_specialities_count_of_type(@specialities_count_by_type)
  end

  def self.call
    return self.instance
  end

  attr_reader :total_beds, :best_beds
  attr_reader :total_branches, :total_providers
  attr_reader :best_waiting_times, :worst_total_waiting_times
  attr_reader :total_satisfaction, :best_satisfaction
  attr_reader :total_private_providers, :total_public_providers
  attr_reader :specialities_count_by_type, :public_specialities_count_of_type, :private_specialities_count_of_type

  private

  def _best_beds
    # Output:
    # {"Adultos"=>470, "Salud Mental"=>177, ...}
    # Returns the best (high) beds' quantity for each area
    # Get all beds ordered by quantity (descending), then group all by area
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

  def _best_waiting_times
    # Output:
    # {"Espera Ginecología"=>0.214e1, "Medicina Interna"=>0.192e1, ...}
    # Returns the best waiting times (lowest) for each speciality
    # Get all waiting times ordered by days, and grouped by speciality name
    @ordered_by_name = {}
    @waiting_times.order(days: :desc).group_by(&:name).map {|name| name[1].first}.each do |waiting_time|
      @ordered_by_name[waiting_time.name] = waiting_time.days
    end
    @ordered_by_name
  end

  def _worst_total_waiting_times
    # Output:
    # 0.1083e3
    # Returns the best provider's total of waiting times
    # Get all waiting times grouped by provider, sum up all waiting times
    @waiting_times.group(:provider_id).sum(:days).pluck(1).sort().last.round(1)
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
