class Codificaorario < ActiveRecord::Base

  has_many :soluzioni
  has_many :prenotazioniaule
  
end
