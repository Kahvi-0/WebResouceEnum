# Old WebEnum

Tool for enumerating websites using the following techniques:

- Directory brute forcing 
    - Using [dirsearch](https://github.com/maurosoria/dirsearch)
    - Set the strength of the brute force list
    - Uses custom list of file extensions
    - Follows redirects
   
    
- Detect CMS and technologies
    - whatweb
    - CMSeeK

- Sorting the results by response code
    - byp4xx ran against every discovered 40X

- Screenshot resources
    - Aquatone

  
  
 All site information is added to an overview HTML page this lives in the root of the project directory that will be created.
 All page screenshots will be added to the aquatone output page.
 A list of all live pages will be in a single text file.
 


## Usage:

    webEnum.sh <http://target> <port> <directory bust level>
    
Name the project (this will create a directory of that same name and all results will live there)
    
  **Directory busting levels**
  
  -1 small list 
  -2 small list + bigger list
  -3 small, big, and huge list
    
   
### Using this script with BURP

**Routing requests through BURP**

Proxy -> Options -> Proxy Listeners -> Add
Binding: port: 8081  Loopback only
Request handling: Redirect to host: <target IP> <target port>
  
  Now run:
  
    webEnum.sh http://127.0.0.1 8081 <directory bust level>
  
**Importing the discovered web resources into Burp**

Retrieve the generated final list of discovered web resources and import to Burp
Find target under sitemap.
Right click -> Scan -> Open scan launcher       
Paste the list of discovered resources into the URLs to scan box.
  
  
# To Do 

- Have specific scans run for detected CMS
- ability to do lists
  - also intake ports as part of the url i.e website.com:8080 and default to 443 or 80 if none is given. 
- Integrate parth to enumerate and fuzz parameters
- Add WebAnalyze
- Dir brute force with other methods than GET
- Proper sorting for directory list output
- add arg 4 for custom wordlist
- add robots.txt analyzer
