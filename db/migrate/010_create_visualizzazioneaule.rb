class CreateVisualizzazioneaule < ActiveRecord::Migration
  def self.up
    create_table :visualizzazioneaule do |t|
    end
  end

  def self.down
    drop_table :visualizzazioneaule
  end
end
