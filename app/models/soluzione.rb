class Soluzione < ActiveRecord::Base

  belongs_to :codificaaula
  belongs_to :codificaorario
  belongs_to :corso
  belongs_to :periododidattico

end
