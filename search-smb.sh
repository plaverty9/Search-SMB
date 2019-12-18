#!/bin/bash

usage(){
	echo -e "Usage: \n$0 \n\t-f [IP or file of hosts to check] \n\t-u [username] (optional) \n\t-p [password] (optional) \n\t-k [keyword to search on] \n\t-d [depth to search] (optional)"
	exit 1
}

while getopts hf:u:p:d:k: option
do
case "${option}"
in
h) usage;;
f) hosts=${OPTARG};;
u) user=${OPTARG};;
p) password=${OPTARG};;
k) keywords=${OPTARG};;
d) depth=${OPTARG};;
esac
done

if [ -z "$hosts" ]
then
	echo "-f is required with an IP or a hosts file"
	exit 1
fi

if [ -z "$keywords" ]
then
        echo "-k is required with a string to search for"
	exit 1
fi
# Checks if the user variable is empty, then it does an unauthenticated search for shares
# If it's not empty
if [ -z "$user" ]
then
	cme smb $hosts --shares > smb-shares.txt
else
	cme smb $hosts -u $user -p $password --shares > smb-shares.txt
fi

# Default search depth is 3 levels, can be set at the command line
if [ -z  "$depth" ]
then
	depth=3
fi

# Just find the shares that have read access
grep -i read smb-shares.txt > grepped-file.txt

# CME adds color to the output, so this strips it out
cat grepped-file.txt | perl -pe 's/\e([^\[\]]|\[.*?[a-zA-Z]|\].*?\a)//g' | col -b > greppedfile.txt

# Don't need this anymore
rm grepped-file.txt

# Start searching!
while read -r line;
do

# The share name is in the 5th column of the CME output
share=$(echo $line | awk '{ print $5 }')

	# If user is blank, we'll search without creds, otherwise, with creds
       if [ -z "$user" ]
        then
                echo "Searching $hosts for $share with keyword $keywords"
                cme smb $hosts --spider $share --depth $depth --pattern $keywords | tee share-data.txt
        else
                echo "Searching $hosts for $share with keyword $keywords with depth $depth"
		echo cme smb $hosts -u $user -p $password --spider $share --depth $depth --pattern $keywords | tee share-data.txt
                cme smb $hosts -u $user -p $password --spider $share --depth $depth --pattern $keywords | tee share-data.txt
        fi


done < greppedfile.txt

#Don't be rude, clean up after yourself.
rm greppedfile.txt
