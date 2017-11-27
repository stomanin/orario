module UtenteHelper
	#ritorna il  nome dell'aula con il relativo link, se presente e se valido
	def link_nome_aula(aula)
		if aula.url=='' or aula.url=='-' or aula.url=='_' or aula.url=='nessuno' or aula.url[0..3]!='http'
				return aula.fullname
			else
				return (link_to aula.fullname, aula.url)
		 end
	end

	#ritorna il nome del corso con il relativo link, se presente e se valido
	def link_nome_corso(corso)
		if corso.link=='' or corso.link=='-' or corso.link=='_' or corso.link=='nessuno' or corso.link[0..3]!='http'
				return corso.nome_corso_esteso
			else
				return (link_to corso.nome_corso_esteso, corso.link)
		 end
	end
	
	
	#ritorna una stringa del tipo "Aula 250 posti", se la capacità dell'aula passata è maggiore di 0
	def capacita_aula(aula)
		if aula.capacita>'0'
			return "Aula "+ aula.capacita +  " posti<br><br>"
		end
	end
	
	#ritorna una stringa del tipo "Videoproiettore fisso<br>", se l'aula passata è dotata di proiettore
	def videoproiettore(aula)
		if aula.videoproiettore=='S' or aula.videoproiettore=='s'
			return "<img src=""http://www.ing.unife.it/gifs/projector.gif"">Videoproiettore fisso<br>"
		end
	end	

	#ritorna una stringa del tipo "Aria condizionata<br>", se l'aula passata è dotata di aria condizionata
	def ariacondizionata(aula)
		if aula.ariacondizionata=='S' or aula.ariacondizionata=='s'
			return "<img src=""http://www.ing.unife.it/gifs/airconditioning.gif"">Aria Condizionata<br><br>"
		end
	end	
	
	#ritorna la data passata nel formato AAAA-MM-GG, scritta correttamente nel formato GG-MM-AAAA
	def reversedate(data)
		return data.to_s.split("-").reverse.join("-")
	end
end
