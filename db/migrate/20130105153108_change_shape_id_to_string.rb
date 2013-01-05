class ChangeShapeIdToString < ActiveRecord::Migration
  def self.up
  	change_column :shapes, :shape_id, :string
  end

  def self.down
  end
end
