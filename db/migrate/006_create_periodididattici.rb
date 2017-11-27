class CreatePeriodididattici < ActiveRecord::Migration
  def self.up
    create_table :periodididattici do |t|
    end
  end

  def self.down
    drop_table :periodididattici
  end
end
