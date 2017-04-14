class RenamePlayerNameColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :pitboss_entries, :player_name, :value
  end
end
