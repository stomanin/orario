class UtenteController < ApplicationController
#========================================================================================
#========================== COSTANTI ====================================================
#========================================================================================

 MINUTI_PER_ORA = 60                # durata delle ore di lezione in minuti
 ORA_PAUSA = "13:30"                # ora pausa pranzo
 PRIMA_ORA_DOPO_LA_PAUSA = "14:00"  # prima ora di lezione dopo la pausa
 GIORNOBASE = "Lunedi"              # giorno da considerare per estrarre le ore dalla
                                    # tabella CODIFICAORARIO

 ARR_GIORNI = ['Lunedi', 'Martedi', 'Mercoledi', 'Giovedi', 'Venerdi']	
                                    # array dei giorni da considerare per la 
                                    # visualizzazione in tabelle

 GRANDE_MAX = 500                   # dimensioni aule
 GRANDE_MIN = 101
 MEDIO_MAX = 100
 MEDIO_MIN = 50
 PICCOLO_MAX = 49
 PICCOLO_MIN = 0

#========================================================================================
#========================== HIDDEN ACTIONS ==============================================
#========================================================================================
 # Azioni non accessibili dall'esterno
 hide_action :lista_ore
 hide_action :ora_fine
 hide_action :ora_di_lezione
 hide_action :calcolo_hash
 hide_action :crea_hash
 
 
 helper_method :ora_fine  #utilizzato anche nell'helper
 
 
 # Ritorna array delle ore ordinate per ora_inizio: filtro le ore per 
 # un giorno della settimana considerato "di base"
 def lista_ore(giornofiltro)
     return Codificaorario.find(:all,
                                :conditions => ["giorno = ?",giornofiltro],
                                :order => "codificaorari.ora_inizio")
 end

 # Ritorna l'ora di fine lezione dati ora di inizio, durata, minuti per 
 # ora (l'ora viene restituita nel formato 11:30)
 def ora_fine(ora_inizio, durata, minuti)
     return (Time.parse(ora_inizio) + durata.to_f()*minuti*60).to_s[11..15] 
 end	

 #ritorna un hash multidimensionale
 def crea_hash
     hash_builder = proc { |h,k| h[k] = Hash.new(&hash_builder) }
     return Hash.new(&hash_builder) 
 end	

 # Funzione per gestire le soluzioni a cavallo della pausa pranzo negli hash
 # INPUT:  ora di fine della lezione precedente rispetto a quella di cui si vuole 
 # calcolare l'ora di lezione
 # OUTPUT: ora reale di inizio dell'ora di lezione (la durata della lezione non tiene
 #         altrimenti conto del fatto che questia sia a cavallo di una pausa)
 def ora_di_lezione(ora_fine)
	if ora_fine == ORA_PAUSA
		ora_lezione = PRIMA_ORA_DOPO_LA_PAUSA
	else
		ora_lezione = ora_fine
	end
    return ora_lezione
 end	
  # Ritorna un hash con indici [giorno][ora] per le soluzioni date (funzione necessaria 
 # alla visualizzazione tabelle)
 # INPUT: soluzioni per una tabella; OUTPUT: hash [giorno][ora]=soluzione corrispondente
 def calcolo_hash(soluzioni, hsh, tipo)
     for s in soluzioni
       # se la durata è maggiore di 1 ora inserisco nell'hash la soluzione 
       # corrispondente anche nelle ore successive
       ora_fine = s.codificaorario.ora_inizio
       for i in 1..((s.durata).to_i)
          case tipo
      		when 'normale'
				hsh[s.codificaorario.giorno][ora_di_lezione(ora_fine)] = s
		    when 'disponibili'
				hsh[s.codificaorario.giorno][ora_di_lezione(ora_fine)].delete(s.codificaaula) 
      		when 'prenotazioni'      			
      			hsh[s.codificaorario.giorno][ora_di_lezione(ora_fine)].push(s)
  	 	  end
          ora_fine = ora_fine(ora_di_lezione(ora_fine), 1, MINUTI_PER_ORA)
       end
     end
     return hsh
 end

#========================================================================================
#========================== ACTIONS =====================================================
#========================================================================================
# Azioni accessibili da web

#===  INDEX  
# Visualizza i link principali alle categorie: calendario, orario lezioni, occupaz laboratori
  def index
    @laboratori = Codificaaula.find(:all, :select =>"DISTINCT tipolab", :conditions => ["laboratorio =?","S"]) 
  end

#===  CALENDARIO  
# Visualizza le date di inizio/fine dei 3 periodi didattici
  def calendario
    @periodididattici = Periododidattico.find(:all)
  end


#===  ORARIOLEZIONI 
# Visualizza i link alle categorie (divisi per periodo didattico): per nomecorso, per 
# cdl/curriculum, per occupazione aule, per occup lab
  def orariolezioni
    @periodididattici = Periododidattico.find(:all)
    @laboratori = Codificaaula.find(:all, :select =>"DISTINCT tipolab", :conditions => ["laboratorio =?","S"]) 
  end

#===  ORARIOLEZIONI  ->  PER_NOMECORSO  
# Visualizza orario delle lezioni in base al nome del corso
  def per_nomecorso
  	#array dei giorni per ordinare i risultati
  	giorni = %w(Lunedi Martedi Mercoledi Giovedi Venerdi Sabato Domenica)
    
    #soluzioni in un dato periodo didattico ordinate per nome del corso, giorno, ora di inizio lezione
 	@soluzioni = Soluzione.find( :all,  
 								 :conditions => ["periododidattico_id = ?",params[:pd]]).sort_by {|soluzioni| 			[soluzioni.corso.nome_corso_esteso,  (giorni.index soluzioni.codificaorario.giorno), soluzioni.codificaorario.ora_inizio]}

  end
#===  ORARIOLEZIONI  ->  PER_CURRICULUM  
# Visualizza la lista degli orari delle lezioni disponibili in base al corso di laurea e al curriculum
 def per_curriculum
 	#curricula raggruppate e ordinate per fullname 
 	@curricula = Curriculum.find(:all,
 								 :conditions => ["da_visualizzare <> ?",'N'],
 								 :order => "curricula.curriculum")
 end

#===  ORARIOLEZIONI  ->  PER_CURRICULUM  ->  PER_CURRICULUM_SPEC  
# Visualizza orario delle lezioni in base al corso di laurea e al curriculum
 def per_curriculum_spec
  	#NB: i corsi "da non visualizzare per curriculum" vengono filtrati nella vista

	#ore ordinate per ora di inizio: filtro le ore per un giorno della settimana considerato "di base"
 	@ore = lista_ore(GIORNOBASE) 
 	
 	@curriculum = Curriculum.find(:first,
 								  :select => "titolo",
 								  :conditions => ["curriculum = ? and anno =?",params[:id],params[:anno]])
 		
	#soluzioni nel pd specificato e con corso_id tale da selezionare l'anno e il curriculum scelti
	@sol_curriculum = Soluzione.find_by_sql ["SELECT * FROM soluzioni WHERE periododidattico_id = ? AND corso_id IN (SELECT corso_id FROM curricula_corsi WHERE curriculum_id IN (SELECT id FROM curricula WHERE anno = ? AND curriculum = ?))", params[:pd], params[:anno], params[:id]] 
	hsh = crea_hash 
	@hsh = calcolo_hash(@sol_curriculum, hsh, 'normale')
 end

#===  ORARIOLEZIONI  ->  PER_OCCUPAZIONE_AULE  
# Visualizza orario delle lezioni in base all'occupazione delle aule 
 def per_occupazione_aule
 	@aule = Codificaaula.find(:all,
	 						:conditions => ["laboratorio =? AND tipolab=?",params[:laboratorio], params[:tipolab]],
 							:order => "codificaaule.fullname")		
 end

#===  ORARIOLEZIONI  ->  PER_OCCUPAZIONE_AULE  -> PER_OCCUPAZIONE_AULE_SPEC
# Visualizza orario delle lezioni in base all'occupazione dell'aula passata per parametro
 def per_occupazione_aule_spec	
	#ore ordinate per ora di inizio: filtro le ore per un giorno della settimana considerato "di base"
 	@ore = lista_ore(GIORNOBASE) 
 	@aula = Codificaaula.find(:first,
 							  :conditions => ["laboratorio =? AND id=?",params[:laboratorio], params[:id]]) 
 	
 	#calcolo hash soluzioni per le aule 
	sol_aule = Soluzione.find( :all,
						 	   :conditions => ["periododidattico_id = ? and codificaaula_id= ?",params[:pd], params[:id]])  
 	hsh = crea_hash
 	@hsh = calcolo_hash(sol_aule, hsh, 'normale')
 	
 	pd = Periododidattico.find(params[:pd])
 	@prenotazioni = Prenotazioneaula.find(:all, :conditions => ["codificaaula_id = ? AND data BETWEEN ? AND ?", params[:id], pd.datainizio, pd.datafine],:order => "data")
 	 
 	#creo hash di array per contenere le prenotazioni (potrebbero esistere piÃ¹ prenotazioni per una sola giornata)
	hsh = crea_hash
  	for ora in @ore
		for giorno in ARR_GIORNI
  				hsh[giorno][ora.ora_inizio] = Array.new
  		end
  	end
  	@hsh_prenotazioni = calcolo_hash(@prenotazioni, hsh, 'prenotazioni')
 end
 
#===  ORARIOLEZIONI  ->  PER_AULE_DISPONIBILI -> PER_AULE_DISPONIBILI
# Visualizza quali aule sono libere
  def per_aule_disponibili
	@ore = lista_ore(GIORNOBASE)   	
  	if params[:laboratorio]=='S' or params[:laboratorio]=='s' 		#laboratori
  		@aule = Codificaaula.find(:all, 
 								:conditions => ["laboratorio = ? and tipolab = ?",params[:laboratorio], params[:tipolab]], :order => "codificaaule.fullname") 
		#creo l'hash completo con tutte le aule (poi sarÃ  modificato togliendo quelle non necessarie))
		@hsh = crea_hash  #hash[giorno][ora]
		@hsh_prenotazioni = crea_hash  #hash[giorno][ora]
	  	for ora in @ore
	  		for giorno in ARR_GIORNI
	  			@hsh[giorno][ora.ora_inizio] = Codificaaula.find(:all, 
	 								:conditions => ["laboratorio = ? and tipolab = ?",params[:laboratorio], params[:tipolab]]) 
	  			@hsh_prenotazioni[giorno][ora.ora_inizio] = Codificaaula.find(:all,
	 								:conditions => ["laboratorio = ? and tipolab = ?",params[:laboratorio], params[:tipolab]])  				
	  		end
	  	end
	else															#aule
		case params[:dim]
		 when 'grande' 
		 	@max = GRANDE_MAX 
		 	@min = GRANDE_MIN 
		 when 'medio'  
			@max = MEDIO_MAX 
			@min = MEDIO_MIN 
		 when 'piccolo'  
			@max = PICCOLO_MAX 
			@min = PICCOLO_MIN 
		end
		
		@aule = Codificaaula.find(:all, 
									:conditions => ["laboratorio = ? and tipolab = ? and capacita between ? and ?",params[:laboratorio], params[:tipolab], @min, @max], :order => "codificaaule.fullname") 

		#creo l'hash completo con tutte le aule (poi sarÃ  modificato togliendo quelle non necessarie))
		@hsh = crea_hash  #hash[giorno][ora]
		@hsh_prenotazioni = crea_hash  #hash[giorno][ora]
	  	for ora in @ore
	  		for giorno in ARR_GIORNI
	  				@hsh[giorno][ora.ora_inizio] = Codificaaula.find(:all,
	 								:conditions => ["laboratorio = ? and tipolab = ? and capacita between ? and ?",params[:laboratorio], params[:tipolab], @min, @max]) 
	
	  				@hsh_prenotazioni[giorno][ora.ora_inizio] = Codificaaula.find(:all,
									:conditions => ["laboratorio = ? and tipolab = ? and capacita between ? and ?",params[:laboratorio], params[:tipolab], @min, @max]) 
	  		end
	  	end		
	end
	
  	#calcolo tutte le soluzioni per pd passato
  	soluzioni = Soluzione.find( :all, :conditions => ["periododidattico_id = ? ",params[:pd]]) 
    calcolo_hash(soluzioni, @hsh, 'disponibili')

  	#calcolo tutte le prenotazioni per pd passato 	
  	pd = Periododidattico.find(params[:pd])
 	prenotazioni = Prenotazioneaula.find(:all, :conditions => ["data BETWEEN ? AND ?", pd.datainizio, pd.datafine])
    calcolo_hash(prenotazioni, @hsh_prenotazioni, 'disponibili')  			
  end
  

#===  ORARIOLEZIONI  ->  PER_CURR_DISPONIBILI -> PER_CURR_DISPONIBILI
# Visualizza quali curriculum sono liberi
  def per_curr_disponibili
	@ore = lista_ore(GIORNOBASE) 
  	
  	@curricula = Curriculum.find(:all, :conditions => ["anno = ?",params[:anno]]) 
  	
	#creo l'hash completo con tutti i cdl (poi sarÃ  modificato togliendo quelle non necessarie))
	@hsh = crea_hash  #hash[giorno][ora]
  	for ora in @ore
  		for giorno in ARR_GIORNI
  				@hsh[giorno][ora.ora_inizio] = Curriculum.find(:all, :conditions => ["anno = ?",params[:anno]]) 
  		end
  	end

  	#calcolo tutte le soluzioni per pd passato e anno
  	@soluzioni = Soluzione.find_by_sql ["SELECT * FROM soluzioni WHERE periododidattico_id = ? AND corso_id IN (SELECT  corso_id FROM curricula_corsi WHERE curriculum_id IN (SELECT id FROM curricula WHERE anno = ?))", params[:pd], params[:anno]] 

  	for sol in @soluzioni
		curr_da_elim = CurriculumCorso.find_by_sql ["SELECT * FROM curricula_corsi WHERE corso_id = ? AND curriculum_id IN (SELECT id FROM curricula WHERE anno = ? )", sol.corso_id, params[:anno]] 
		for c in curr_da_elim
			ora_fine = sol.codificaorario.ora_inizio
	 		for i in 1..((sol.durata).to_i)
  				@hsh[sol.codificaorario.giorno][ora_di_lezione(ora_fine)].delete(c.curriculum)  
  				ora_fine = ora_fine(ora_di_lezione(ora_fine), 1, MINUTI_PER_ORA)
  			end
  		end
  	end	
  end

#===  ORARIOLAB  
# Visualizza i link all'orario del lab divisi per periodo didattico
  def orarioaule
  	@periodididattici = Periododidattico.find(:all)
  end

  def per_prenotazioni_aule
  	@aule = Codificaaula.find(:all,
	 		:conditions => ["laboratorio =? AND tipolab=?",params[:laboratorio], params[:tipolab]],
 			:order => "codificaaule.fullname")
  end	
  

#===  ORARIOLEZIONI  ->  PER_OCCUPAZIONE_AULE  -> PER_PRENOTAZIONI_AULE_SPEC
# Visualizza orario delle prenotazioni per l'aula selezionata
 def per_prenotazioni_aule_spec
	#ore ordinate per ora di inizio: filtro le ore per un giorno della settimana considerato "di base"
 	@ore = lista_ore(GIORNOBASE) 
 	@aula = Codificaaula.find(:first,
 							  :conditions => ["laboratorio =? AND id=?",params[:laboratorio], params[:id]]) 
 	
	if params[:datainizio]==nil
	 	@prenotazioni = Prenotazioneaula.find(:all, :conditions => ["codificaaula_id = ? AND data <= ?", params[:id], params[:datafine]],:order => "data")		
elsif params[:datafine]==nil
	 	@prenotazioni = Prenotazioneaula.find(:all, :conditions => ["codificaaula_id = ? AND data >= ?", params[:id], params[:datainizio]], :order => "data")				
	else
	 	@prenotazioni = Prenotazioneaula.find(:all, :conditions => ["codificaaula_id = ? AND data BETWEEN ? AND ?", params[:id], params[:datainizio], params[:datafine]],:order => "data")		
	end
 	 
 	#creo hash di array per contenere le prenotazioni (potrebbero esistere piÃ¹ prenotazioni per una sola giornata)
	hsh = crea_hash
  	for ora in @ore
		for giorno in ARR_GIORNI
  				hsh[giorno][ora.ora_inizio] = Array.new
  		end
  	end
	@hsh_prenotazioni = calcolo_hash(@prenotazioni, hsh, 'prenotazioni')
 end

end