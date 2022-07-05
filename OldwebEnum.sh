#!/bin/bash
helpscreen () {

        echo ''
        echo 'Usage web.sh <http(s)://target> <port> <bust level>'
        echo ''
        echo '-----------------------------------------------------------'
        echo 'Flags:'
        echo '	Directory bust level:   '
        echo '				-1: light'
        echo '				-2: heavy'
        echo '				-3: really heavy'
        echo ''
        echo '-----------------------------------------------------------'
        echo ''
        echo 'Used With Burp:'
        echo '  1. Routing through Burp:'
        echo '      Proxy -> Options -> Proxy Listeners -> Add'
        echo '        Binding: port: 8081  Loopback only'
        echo '        Request handling: Redirect to host: <target IP> <target port>'
        echo ''
        echo '  2. Retrieve the generated final list of discovered web resources and import to Burp'
        echo '     Find target under sitemap.  '
        echo '     Right click -> Scan -> Open scan launcher'        
        echo '     Paste the list of discovered resources into the URLs to scan box.'
        echo ''
        echo ''
        exit 2
        }
        
#Syntax checks

if ! [[ $1 =~ ^'http' ]]; then
	echo "no http"
	helpscreen
fi

if ! [ "$#" = 3 ]; then
	echo "need 3"
	helpscreen
fi

echo "what is the project name?"
read project

echo -e "\n\n[+] preparing project directories and files\n\n"
mkdir $project
mkdir $project/directories
mkdir $project/vulnScan
mkdir -p $project/directories/screenshots/100
mkdir -p $project/directories/screenshots/200
mkdir -p $project/directories/screenshots/300
mkdir -p $project/directories/screenshots/400
mkdir -p $project/directories/screenshots/500
mkdir -p $project/tools
mkdir -p $project/tools/aquatone
mkdir -p $project/logs
touch $project/overview.html

# Downloading tools
git -C $project/tools/ clone --quiet https://github.com/maurosoria/dirsearch.git
git -C $project/tools/ clone --quiet https://github.com/Tuhinshubhra/CMSeeK
git -C $project/tools/ clone --quiet https://github.com/lobuhi/byp4xx.git
pip3 install -r $project/tools/CMSeeK/requirements.txt
wget -q https://raw.githubusercontent.com/Kahvi-0/Tools-and-Concepts/master/Toolbox/Web/wordlists/common_extensions.txt
wget -q https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip -O $project/tools/aquatone/aquatone.zip && unzip $project/tools/aquatone/aquatone.zip -d $project/tools/aquatone/

clear -x

echo "Bitter Sweet Enumerator"


#fix 
#echo "<h1>CMS details</h1>" >> $project/overview.html
#echo "" | python3 $project/directories/CMSeeK/cmseek.py -u $1 | grep -oE "(Detected CMS.*)" >> $project/overview.html
#echo "" | python3 $project/directories/CMSeeK/cmseek.py -u $1 | grep -oE "(........Version.*)" >> $project/overview.html
#echo "" | python3 $project/directories/CMSeeK/cmseek.py -u $1 | grep -oE "(^.*vulnerabilities.*)" >> $project/overview.html

echo "<PRE>" >> $project/overview.html
whatweb -v -color=never $1:$2 >> $project/overview.html
echo "</PRE>" >> $project/overview.html

## Add specific scanners for discovered CMS
## Add results of those scanners to direcotry list / certain output to the file
## Scrape robots.txt for directories 

echo -e "\n\n[+] dirsearchings\n\n"
#light busting
if [ $3 == -1 ]; then
python3 $project/tools/dirsearch/dirsearch.py -u  $1:$2 -m GET,POST,PUT,DELETE,CONNECT -e extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs.txt
echo -e "\n\n[+] common.txt\n\n"
python3 $project/tools/dirsearch/dirsearch.py -u  $1:$2 -m GET,POST,PUT,DELETE,CONNECT -w /usr/share/wordlists/dirb/common.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs1.txt
cat $project/directories/dirs.txt $project/directories/dirs1.txt  | sort -u >  $project/directories/FinalList.txt
fi

#heavy busting
if [ $3 == -2 ]; then
python3 $project/tools/dirsearch/dirsearch.py -u  $1:$2 -m GET,POST,PUT,DELETE,CONNECT -e extensions.txt -r -t 50 --plain-text-report=$project/directories/dirs.txt
echo -e "\n\n[+] common.txt\n\n"
python3 $project/tools/dirsearch/dirsearch.py -u  $1:$2 -m GET,POST,PUT,DELETE,CONNECT -w /usr/share/wordlists/dirb/common.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs1.txt
echo -e "\n\n[+] directory-list-2.3-medium.txt\n\n"
python3 $project/tools/dirsearch/dirsearch.py -u  $1:$2 -m GET,POST,PUT,DELETE,CONNECT -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs2.txt
cat $project/directories/dirs.txt $project/directories/dirs1.txt $project/directories/dirs2.txt | sort -u >  $project/directories/FinalList.txt
fi

#really heavy busting
if [ $3 == -3 ]; then
python3 $project/tools/dirsearch/dirsearch.py -u  $1:$2 -m GET,POST,PUT,DELETE,CONNECT -e extensions.txt -r -t 50 --plain-text-report=$project/directories/dirs.txt
echo -e "\n\n[+] common.txt\n\n"
python3 $project/tools/dirsearch/dirsearch.py -u  $1:$2 -m GET,POST,PUT,DELETE,CONNECT -w /usr/share/wordlists/dirb/common.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs1.txt
echo -e "\n\n[+] directory-list-2.3-medium.txt\n\n"
python3 $project/tools/dirsearch/dirsearch.py -u  $1:$2 -m GET,POST,PUT,DELETE,CONNECT -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs2.txt
echo -e "\n\n[+] directory-list-lowercase-2.3-medium.txt\n\n"
python3 $project/tools/dirsearch/dirsearch.py -u  $1:$2 -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt -e common_extensions.txt -F -r -t 50 --plain-text-report=$project/directories/dirs3.txt
cat $project/directories/dirs.txt $project/directories/dirs1.txt $project/directories/dirs2.txt $project/directories/dirs3.txt | sort -u >  $project/directories/FinalList.txt
fi


echo -e "\n\n[+] Sorting results\n\n"
#sort results into seperate files by status
cat $project/directories/FinalList.txt | grep ^"1" | grep -oP "((?=http).*)" > $project/directories/100status.txt
cat $project/directories/FinalList.txt | grep ^"2" | grep -oP "((?=http).*)" > $project/directories/200status.txt
cat $project/directories/FinalList.txt | grep ^"3" | grep -v "REDIRECTS TO: " | grep -oP "((?=http).*)" > $project/directories/300status.txt
cat $project/directories/FinalList.txt | grep ^"4" | grep -oP "((?=http).*)" > $project/directories/400status.txt
cat $project/directories/FinalList.txt | grep ^"5" | grep -oP "((?=http).*)" > $project/directories/500status.txt


#Attempts to bypass discovered 403 
cat $project/directories/FinalList.txt | grep ^"403" | grep -oP "((?=http).*)" > $project/directories/403.txt
echo "<h1>byp4xx output</h1>" >> $project/overview.html
echo "<pre>" >> $project/overview.html
echo "" >> $project/overview.html
for x in $(cat $project/directories/403.txt)
do
	 $project/tools/byp4xx/byp4xx.sh -r -c $x | grep -E -- "200|301|302" >> $project/overview.html
done;
echo "</pre>" >> $project/overview.html
	
#Producing the final directory list
cat $project/directories/FinalList.txt | grep -oP "((?=http).*)" > $project/discovered.txt

#Screenshots from aquatone
echo -e "\n\n[+] Grabbing screenshots using aquatone\n\n"
cat $project/directories/*status.txt | $project/tools/aquatone/aquatone -silent -ports $2 -out $project

clear -x
echo ''
echo "Web enumeration completed for $1"
echo "Output file found in $project/overview.html"
echo "List of all discovered directories found here: $project/discovered.txt"

#open all result pages 

sensible-browser $project/overview.html $project/aquatone_report.html $project/discovered.txt 

#clean up section
echo -e "\n\n[+] Cleaning up\n\n"
rm -f $project/directories/dirs.txt
rm -f $project/directories/dir2.txt
rm -f $project/directories/dir3.txt
rm -f $project/directories/FinalList.txt
rm -rf $project/directories/webscreenshot
rm -rf $project/directories/dirsearch
rm ./common_extensions.txt
