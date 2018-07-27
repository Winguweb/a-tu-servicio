class RenameProvidersTable < ActiveRecord::Migration[5.2]
  def self.up
    rename_table :providers, :providers_old
  end

  def self.down
    rename_table :providers_old, :providers
  end
end
