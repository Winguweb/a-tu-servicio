class SearchService
  include Singleton

  def initialize

  end

  def self.call
    return self.instance
  end

  def search(query, page = 1)
    Branch.search(query)
  end
end
