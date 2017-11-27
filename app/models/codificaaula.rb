class Codificaaula < ActiveRecord::Base
	
  has_many :soluzioni
  has_many :prenotazioniaule
  has_one  :visualizzazioneaula

end
