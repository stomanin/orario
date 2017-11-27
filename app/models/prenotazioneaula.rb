class Prenotazioneaula < ActiveRecord::Base

  belongs_to :codificaaula
  belongs_to :codificaorario
  belongs_to :corso
	
end
