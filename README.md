# Search-SMB
A wrapper shell script for CrackMapExec (https://github.com/byt3bl33d3r/CrackMapExec) that will grab all the SMB shares and search readable ones for your search term.

./search-smb-shares.sh 
	 -f [IP or file of IPs to check] 
	 -u [username] (optional) 
	 -p [password] (optional) 
	 -k [search term, ie. password, ssn, tax, client] 
	 -d [depth to search] (optional)
  
Don't include the domain with the username

When it finishes, it'll output to a file named share-data.txt
