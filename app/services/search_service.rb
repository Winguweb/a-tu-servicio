class SearchService
  include Singleton

  def initialize

  end

  def self.call
    return self.instance
  end

  def search(query, page = 1)
    Branch.search(query, {
      includes: [:provider],
      where: {
        georeference: {not: nil}
      },
      match: :word_start,
      misspellings: {
        edit_distance: 2
      },
      fields: [:name, :provider_name, :address, :specialities],
      order: {name: :asc},
      page: page,
      per_page: 50
    })
  end

  private
end
