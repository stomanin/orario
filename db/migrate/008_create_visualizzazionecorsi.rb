class CreateVisualizzazionecorsi < ActiveRecord::Migration
  def self.up
    create_table :visualizzazionecorsi do |t|
    end
  end

  def self.down
    drop_table :visualizzazionecorsi
  end
end
