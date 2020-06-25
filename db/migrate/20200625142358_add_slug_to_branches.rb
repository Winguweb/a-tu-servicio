class AddSlugToBranches < ActiveRecord::Migration[5.2]
  def change
    add_column :branches, :slug, :string

    Branch.find_each do |branch|
      branch.slug = branch.name.parameterize
      branch.save!
    end
  end
end
