# coding: utf-8
# Helper for values we want to show in the home page
#
module HomeHelper
  def waiting_time_percent(name, days)
    unless @waiting_times
      @waiting_times = {}
      @providers.each do |provider|
        provider.waiting_times.each do |waiting_time|
          @waiting_times[waiting_time.name] = waiting_time.days.to_f > @waiting_times[waiting_time.name].to_f ? waiting_time.days.to_f : @waiting_times[waiting_time.name].to_f
        end
      end
    end
    number_with_precision(days / @waiting_times[name] * 100, :precision => 2)
  end

  def cost_percent(name, amount)
    unless @costs
      @costs = {}
      @providers.each do |provider|
        provider.costs.each do |cost|
          @costs[cost.name] = cost.amount > @costs[cost.name].to_f ? cost.amount.to_f : @costs[cost.name].to_f
        end
      end
    end
    number_with_precision(amount / @costs[name] * 100, :precision => 2)
  end

  def affiliation_percent(percentage)
    unless @affiliations
      @affiliations = @providers.sum(&:affiliations).to_f
    end
    number_with_precision(percentage / @affiliations * 100, :precision => 2)
  end

  def speciality_percent(name, professionals_count)
    unless @specialities
      @specialities = {}
      @providers.each do |provider|
        provider.specialities.each do |speciality|
          @specialities[speciality.name] = speciality.professionals_count.to_f > @specialities[speciality.name].to_f ? speciality.professionals_count.to_f : @specialities[speciality.name].to_f
        end
      end
    end
    number_with_precision(professionals_count / @specialities[name] * 100, :precision => 2)
  end

  def branches_levels_count(provider)
    branches = provider.branches
    levels = branches.map(&:levels)
    levels_count = *levels.flatten.group_by(&:name).transform_values(&:count)
  end

  def get_provider_branch_states(provider)
    provider.branches.map(&:state).map(&:name).uniq.join(', ')
  end
end
