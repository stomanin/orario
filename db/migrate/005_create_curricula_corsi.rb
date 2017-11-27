class CreateCurriculumCorsi < ActiveRecord::Migration
  def self.up
    create_table :curricula_corsi do |t|
    end
  end

  def self.down
    drop_table :curricula_corsi
  end
end
