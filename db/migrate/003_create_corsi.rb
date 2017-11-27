class CreateCorsi < ActiveRecord::Migration
  def self.up
    create_table :corsi do |t|
    end
  end

  def self.down
    drop_table :corsi
  end
end
