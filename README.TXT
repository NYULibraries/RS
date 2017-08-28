RS2017_autoExtract.pl
	About:  attempts to extract information such as paginated page range, front matter page range, back matter page range etc.
	Input:  directory you wish to check
	Output: an argument list that 
	Usage:  perl RS2017_autoExtract.pl <path to directory>
	Necessary script.
------------------------------
RS2017_exist.pl
	About:  uses an argument list to verify that EOC exists, target file exists,  pages within page ranges exist, no hidden files/folders, files are named properly
	Input:  argument list e.g. -dir=path/to/dir -pstart=1 -pend=123 -frstart=1 -frend=20 -bkstart=1 -bkend=20 etc…
	Output: a string ready to be displayed on a terminal
	Usage:  perl RS2017_exist.pl <argument list>
	Necessary script.
------------------------------
RS2017_simpleReport.pl
	About:  uses an argument list to display a summary of the contents of the object i.e. partner, collection code, unit of work, page start, page end, etc…
	Input:  argument list e.g. -dir=path/to/dir -pstart=1 -pend=123 -frstart=1 -frend=20 -bkstart=1 -bkend=20 etc…
	Output: a string ready to be displayed on a terminal
	Usage:  perl RS2017_simpleReport.pl <argument list>
	Necessary script.
------------------------------
RS2017.config
	About:  stores values of selected buttons, roles, naming convention etc. for the RS2017.pl script and for the GUI
	Input:  none
	Output: none
	Usage:  modify the contents of the file, comment out lines using // (the java GUI can automatically set the contents of the file)

	More:
	//This is a comment. It comments out the entire line. 
    	//This line will also be ignored.
	//the information is stored as a pair as follows: option = value

	//batch can be either true or false
	//when set to true, batch does not allow for much user interaction
	//when set to false, batch allows for user interaction via the terminal
	//batch = true

	//hyphen can be either true of false
	//when true hyphen sets the front matter notation to  -fr
	//when false hyphen sets the front matter notation to _fr
	//hyphen = false

	//target_exists can be either true or false
	//this option tells the RS2017 script whether or not to display an error when a target file is not found
	//target_exists = true

	//eoc_exists can be either true or false
	//this option tells the RS2017 script whether or not to display an error when a doc file is not found
	//eoc_exists = true
	
	//this specifies the roles to check
	//sample roles for postcards using recto/verso naming convention
	//add_role = r_m
	//add_role = r_d
	//add_role = v_m
	//add_role = v_d

	//sample roles for archival material
	//add_role = m
	//add_role = d

	//if roles are not specified, they will not be included

	//you can specify your own roles by adding them as follows
	//please change the GUI option role_other from false to true, when making your own roles
	//note that there is no leading underscore or hyphen when adding roles
	//add_role = your_first_role_here
	//add_role = your_second_role_here

	//these are GUI options, which set radio buttons; (role_postcard is also used by the RS2017)
	//role_none = false
	//role_archival = true
	//role_postcard = false
	//role_other = false

	//the following options can be omitted but will change the default behavior
	//additionally, you can specify:
		//manually specify the first paginated page instead of automatically finding the first paginated page
		//example: situation: A book should start on page 1 but starts on page 2; Result: If the program finds no other problem it will pass the book, but if that behavior is unwanted it can be overridden
		//use <integers>
		//pstart = 1
	
		//the first front matter page <integers>
		//frstart = 1

		//the first back matter page <integers>
		//bkstart = 1		
        
			
		
	//the above options can be used as follows in this working config file example:
	batch = true

	hyphen = false

	eoc_exists = true
	target_exists = true

	add_role = m
	add_role = d

	role_none = false
	role_archival = true
	role_postcard = false
	role_other = false

	pstart  = 1
	frstart = 1
	bkstart = 1
	

	//Necessary file.
------------------------------
RS2017.pl
	About:  this script reads RS2017.config, calls RS2017_autoExtract.pl to get an argument list, followed by RS2017_simpleReport.pl to display what it found, followed by RS2017_exist.pl to check the naming, hidden files, etc.
	Input:  list of folders separated by a space character
	Output: a string ready to be displayed on the terminal
	Usage:  perl RS2017.pl <list of directories separated by a space character>
	Necessary script.
------------------------------
RS2017a.jar
	About:  this is a graphical user interface for the RS2017.pl script. It can modify the config file as the user clicks on buttons and checkboxes. It calls the RS2017.pl script and shows the result on the side.
	Input:  none
	Output: none
	Usage:  double click the RS2017a.jar file to run.
	Not necessary unless a GUI is desired.
------------------------------
