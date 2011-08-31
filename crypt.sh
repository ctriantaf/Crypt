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


VERSION=2.0
_height=300
_width=500



	if [ -e != /home/$USER/.crypt_list ]
		then  touch /home/$USER/.crypt_list
	
	fi
	
	
	if [ -e != /home/$USER/.crypt_list_open ]
		then  touch /home/$USER/.crypt_list_open
	
	fi
	
#
# Έλεγχος για κλείσιμο zenity
#
	
	zenity_fail() {
		if [ $? != 0 ]; then
			menu
		fi
		
	}

#
#Δημιουργία φακέλου
#
	
	create_folder() {
		
		name=`zenity --entry --title="Ονομασία φακέλου:" --text="Όνομα φακέλου;"`
		
		zenity_fail
		
		mkdir /home/$USER/$name && mkdir /home/$USER/.$name  
		
		encfs --standard --extpass='zenity --entry --hide-text --title="Κωδικός" --text="Παρακαλώ πληκτρολογίστε τον κωδικό που θέλετε."' /home/$USER/.$name /home/$USER/$name 
		
		menu
		
		echo $name >> /home/$USER/.crypt_list
		
	}
	
#
# Άνοιγμα φακέλου
#
	
	open_folder() {
		
		zenity --height=$_height --width=$_width \
		--text-info --title="Φάκελοι που υπάρχουν" --filename=/home/$USER/.crypt_list
		
		zenity_fail
		
		name=`zenity --entry --title="Άνοιγμα φακέλου" --text="Δώστε το όνομα του φακέλου που θέλετε να ανοίξετε."`
		
		zenity_fail
		
		encfs --extpass='zenity --entry --hide-text --title="Κωδικός" --text="Παρακαλώ πληκτρολογίστε τον κωδικό."' /home/$USER/.$name /home/$USER/$name
		
		echo $name >> /home/$USER/.crypt_list_open
		
		menu
	}
	
#	
# Κλείσιμο φακέλου
#

	close_folder() {
		
		
		if [ -s /home/$USER/.crypt_list_open ]; then
			zenity --height=$_height --width=$_width \
			--text-info --title="Φάκελοι που είναι ανοιχτοί." --filename=/home/$USER/.crypt_list_open
		
		zenity_fail
			
		elif [ ! -s /home/$USER/.crypt_list_open ]; then
			zenity --info --text="Δεν υπάρχουν ανοιχτοί φάκελοι."
		
		zenity_fail
		
			menu
		fi
		
		
		close_name=`zenity --entry --title="Κλείσιμο φακέλου" --text="Δώστε το όνομα του φακέλου που θέλετε να κλείσετε."`
	 
		zenity_fail
		
		fusermount -u /home/$USER/$close_name && rmdir /home/$USER/$close_name
		
		menu
	}

#
# Προσθήκη φακέλου
#

	import_folder() {
		
		zenity --warning --title="Προσοχή" --text="Ο φάκελος πρέπει να είναι στο /Home."
		folder=`zenity --file-selection --directory --title="Επιλέξτε τον φάκελο."`
		
		zenity_fail
		
		name=`zenity --entry --title="Προσθήκη φακέλου" --text="Δώστε το όνομα που θέλετε να έχει ο φάκελος (καλύτερα το ίδιο με το κρυφό φάκελο)."`
		
		zenity_fail
		
		echo $name >> /home/$USER/.crypt_list		
		
		encfs /home/$USER/.$folder /home/$USER/$name
		
		menu
	 }

#
# Διαγραφή φακέλου
#
	
	delete_folder() {
		
		
		if [ -s /home/$USER/.crypt_list ]; then
			zenity --height=$_height --width=$_width \
			--text-info --title="Φάκελοι που υπάρχουν." --filename=/home/$USER/.crypt_list
		
		zenity_fail
			
		elif [ ! -s /home/$USER/.crypt_list ]; then
			zenity --info --text="Δεν υπάρχουν φάκελοι."
		
		zenity_fail
		
			menu
		fi
		
		
		folder=`zenity --entry --title="Διαγραφή φακέλου" --text="Διαλέξτε ποιον θέλετε να διαγράψετε."`
		
		zenity_fail
		
		zenity --question --title="Διαγραφή φακέλου" --text="Θέλετε να διαγράψετε και τον κρυφό φάκελο με το στοιχεία;"
		
		zenity_fail
		
		if [ $? == 0 ];
				then rm -rf /home/$USER/$folder && sudo rm -rf /home/$USER/.$folder
         
        elif [ $? != 0 ]
				then rm -rf /home/$USER/$folder
        fi
		
		sed -i "/$folder/d" /home/$USER/.crypt_list
		
		menu
	}
		
#
# Backup
#

	backup() {
		
		folder=`zenity --file-selection`
		
		tar -cf /home/$USER/$folder-backup.tar $folder
		
		if [ $? != 0 ];
			then zenity --error --title="Αποτυχία" --text="Το backup απέτυχε."
		
		zenity_fail
		
		elif [ $? == 0 ];
			then zenity --info --title="Ολοκληρώθηκε" --text="Το backup ολοκληρώθηκε."
		
		zenity_fail
		
		fi
		
		menu
	}
	
#
# Restore
#
	
	restore() {
		
		archive=`zenity --file-selection`
		
		tar -xf $archive
		
		zenity --question --title="Προσθήκη φακέλου" --text="Θέλετε να προσθέσετε τον φάκελο;"
		
		zenity_fail
		
		if [ $? == 0 ];
			then name1=`zenity --entry --title="Ονομασία" --text="Τι όνομα να έχει ο κρυφός φάκελος;"`
		
		zenity_fail
					
				 name2=`zenity --entry --title="Ονομασία" --text="Τι όνομα να έχει ο ορατός φάκελος;"`
	
	zenity_fail
					
				echo $name2 >> /home/$USER/.crypt_list	
				encfs --standard --extpass='zenity --entry --hide-text --title="Κωδικός" --text="Παρακαλώ πληκτρολογίστε τον κωδικό που θέλετε."' /home/$USER/.$name1 /home/$USER/$name2;
		
		else menu
		fi
		
		menu
	}
			
# 
# Μενού
#

	menu() {


input=$(zenity --height=450 --width=650 \
		--title="Διαλέξτε τι θέλετε να κάνετε:" \
		--list \
		--radiolist \
		--column="" \
		--column="#" \
		--column="Επιλογή" \
		"false" "1" "Δημιουργήστε ένα κρυπτογραφημένο φάκελο." \
		"false" "2" "Να ανοίξετε κάποιον φάκελο." \
		"false" "3" "Να κλείσετε κάποιον φάκελο." \
		"false" "4" "Προσθέστε κάποιον ήδη υπάρχων φάκελο." \
		"false" "5" "Διαγράψτε κάποιον φάκελο." \
		"false" "6" "Backup." \
		"false" "7" "Επαναφορά backup." \
		"true" "*" "Έξοδος." \
		--separator=";")
		
		if [ $? != 0 ]; then
			mainmenu
		else

		for i in $(echo $input | tr ";" "\n")
			do
		
  case $i in
  
  1) create_folder;; 
  2) open_folder;;
  3) close_folder;;
  4) import_folder;;
  5) delete_folder;;
  6) backup;;
  7) restore;;
  *) exit 0;;
  esac
			done
		fi

	}
	
	menu
