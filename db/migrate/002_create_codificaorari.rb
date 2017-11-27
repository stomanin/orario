class CreateCodificaorari < ActiveRecord::Migration
  def self.up
    create_table :codificaorari do |t|
    end
  end

  def self.down
    drop_table :codificaorari
  end
end
