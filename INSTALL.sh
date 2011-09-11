#!/bin/bash

#
# Εγκατάσταση του προγράμματος
#

	printf "Θα μπορείτε να τρέξετε το πρόγραμμα γράφοντας crypt σε ενα τερματικό ή να το βρείτε στο μενού \n Πληκτρολογίστε τον κωδικό σας για να γίνουν οι απαραίτητες αλλαγές \n"
	
	cd /home/$USER/Crypt/
	sudo cp crypt.sh /usr/bin/crypt
	
	
	cp crypt.desktop /home/$USER/.local/share/applications/
	sudo chmod +x /home/$USER/.local/share/applications/crypt.desktop
