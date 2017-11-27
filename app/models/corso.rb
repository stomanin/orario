class Corso < ActiveRecord::Base

  has_many :soluzioni
  has_many :curricula_corsi
  has_many :prenotazioniaule
  has_one  :visualizzazionecorso
  
end
