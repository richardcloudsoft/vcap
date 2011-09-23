class AddNextInstanceIdToApp < ActiveRecord::Migration
  def self.up
    add_column :apps, :next_instance_id, :integer, :null => false, :default => 0
    add_column :apps, :instance_ids, :string, :null => false, :default => ''
    remove_column :apps, :instances
  end

  def self.down
    remove_column :apps, :next_instance_id
    remove_column :apps, :instance_ids
    add_column :apps, :instances, :integer, :default => 0
  end
end
