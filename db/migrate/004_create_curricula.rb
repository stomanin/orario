class CreateCurricula < ActiveRecord::Migration
  def self.up
    create_table :curricula do |t|
    end
  end

  def self.down
    drop_table :curricula
  end
end
