


## Urls
### gau
echo "gau"
cat $domain | gau --subs --o urls1.txt

### waybackurls
echo "waybackurls"
cat $domain | waybackurls >> urls1.txt
