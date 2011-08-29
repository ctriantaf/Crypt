#!/bin/bash
#
#       crypt.sh
#       
#       Copyright 2011 Chris Triantafillis <christriant1995@gmail.com>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, see <http://www.gnu.org/licenses/>
#		or write to the Free Software Foundation, Inc., 51 Franklin Street,
#		Fifth Floor, Boston, MA 02110-1301, USA.
#       
# 
	if [ -e != .crypt_list ]
		then  touch .crypt_list
	
	fi
	
	
	if [ -e != .crypt_list_open ]
		then  touch .crypt_list_open
	
	fi

#
#Δημιουργία φακέλου
#
	
	create_folder() {
		
		printf "Ονομασία φακέλου: \n"
			read name
	 
		mkdir $name && mkdir .$name  
		
		echo $name >> .crypt_list
		
		encfs --standard --extpass='zenity --entry --hide-text --title="Κωδικός" --text="Παρακαλώ πληκτρολογίστε τον κωδικό που θέλετε."' /home/$USER/.$name /home/$USER/$name 
		
		menu
	}
	
#
# Άνοιγμα φακέλου
#
	
	open_folder() {
		
		printf "Λίστα με τους φακέλους \n "
		cat .crypt_list
		printf "Δώστε το όνομα του φακέλου που θέλετε να ανοίξετε \n "
		
		read name
		
		encfs --extpass='zenity --entry --hide-text --title="Κωδικός" --text="Παρακαλώ πληκτρολογίστε τον κωδικό."' /home/$USER/.$name /home/$USER/$name
		
		echo $name >> .crypt_list_open
		
		menu
	}
	
#	
# Κλείσιμο φακέλου
#

	close_folder() {
		
		printf "Οι φάκελοι που είναι ανοιχτοί είναι (αν δεν δείχνει \n τίποτα σημαίνει ότι δεν υπάρχουν ανοιχτοί φάκελοι) : "
		
		cat .crypt_list_open
		
		
		printf "Δώστε το όνομα του φακέλου που θέλετε να κλείσετε \n "
			read close_name 
	 
		fusermount -u /home/$USER/$close_name && rmdir $close_name
		
		menu
	}

#
# Προσθήκη φακέλου
#

	import_folder() {
		
		printf "Ο φάκελος πρέπει να είναι στο /Home \n "
		zenity --file-selection --directory --title="Επιλέξτε τον φάκελο \n "
		read folder
		
		printf "Δώστε το όνομα που θέλετε να έχει ο φάκελος (καλύτερα το ίδιο με το κρυφό φάκελο) \n "
		read name
	 
		echo $name >> .crypt_list		
		
		encfs /home/$USER/.$folder /home/$USER/$name
		
		menu
	 }

#
# Διαγραφή φακέλου
#
	
	delete_folder() {
		
		printf "Οι φάκελοι που υπάρχουν είναι: \n "
		cat .crypt_list
		
		printf "Διαλέξτε ποιον θέλετε να διαγράψετε \n"
		read folder
		
		printf "Θέλετε να διαγράψετε και τον κρυφό φάκελο με το στοιχεία; (ν/ο) \n"
		read answer
		
		if [ "$answer" == "ν" ]
         then sudo rm -rf $folder .$folder
         
         
			elif [ "$answer" == "ο" ]
				then sudo rm -rf $folder
         
			elif [ "$answer" != "ν" ] || [ "$answer" != "ο" ]
				then
					while [ "$answer" != "ν" ] && [ "$answer" != "ο" ]; do
					printf "Θέλετε να διαγράψετε και τον κρυφό φάκελο με το στοιχεία; (ν/ο) \n"
					read answer;		
					done
		fi
		
		sed -i "/$folder/d" .crypt_list
		
		menu
	}
		
#
# Backup
#

	backup() {
		
		printf "Δώσε το όνομα του φακέλου που θέλετε να κάνετε backup"
		read folder
		
		tar -cf $folder-backup.tar.gz $folder
		
		if [ $? != 0 ];
			then zenity --error --title="Αποτυχία" --text="Το backup απέτυχε."
		elif [ $? == 0 ];
			then zenity --info --title="Ολοκληρώθηκε" --text="Το backup ολοκληρώθηκε."
		fi
		
		menu
	}
	
#
# Restore
#
	
	restore() {
		
		zenity --file-selection
		read archive
		
		tar -xf $archive
		
		printf "Θέλετε να προσθέσετε τον φάκελο; (ν/ο) "
		read answer
		
		if [ $answer == ν ];
			then printf "Τι όνομα να έχει το ο κρυφός φάκελος;"
					read name1
					
				 printf "Τι όνομα να έχει το ο ορατός φάκελος;"
					read name2
					
				echo $name2 >> .crypt_list	
				encfs --standard --extpass='zenity --entry --hide-text --title="Κωδικός" --text="Παρακαλώ πληκτρολογίστε τον κωδικό που θέλετε."' /home/$USER/.$name1 /home/$USER/$name2;
		
		else menu
		fi
		
		menu
	}
			
# 
# Μενού
#

	menu() {
	
printf "Διαλέξτε τι θέλετε να κάνετε: \n "
printf "1) Δημιουργήστε ένα κρυπτογραφημένο φάκελο. \n 2) Να ανοίξετε κάποιον φάκελο. \n "
printf "3) Να κλείσετε κάποιον φάκελο. \n 4) Προσθέστε κάποιον ήδη υπάρχων φάκελο. \n "
printf "5) Διαγράψτε κάποιον φάκελο \n *) Έξοδος. \n "

read i

  case $i in
  
  1) create_folder;; 
  2) open_folder;;
  3) close_folder;;
  4) import_folder;;
  5) delete_folder;;
  *) exit 0;;
  esac

	}
	
	menu
