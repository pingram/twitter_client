class ModifyStatusStrings < ActiveRecord::Migration
  def change
    change_column :statuses, :twitter_status_id, :string, :null => false
  end
end
