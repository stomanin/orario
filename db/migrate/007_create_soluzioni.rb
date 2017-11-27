class CreateSoluzioni < ActiveRecord::Migration
  def self.up
    create_table :soluzioni do |t|
    end
  end

  def self.down
    drop_table :soluzioni
  end
end
