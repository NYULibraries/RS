#!/usr/bin/perl
=pod
Copyright (c) 2017 Wilfredo Rosario

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

This file and others are available at
https://github.com/WilfredoRosario/RS

=cut

#fix the arguments as they come from the command line
$ARGUMENT_STRING=join(' ',@ARGV);
#print "\nSTRING:$ARGUMENT_STRING\n";
@ARGV=();
(@ARGV)=split(/ +-+/,$ARGUMENT_STRING);
#print scalar(@ARGV)." ELEMENTS1\n";
foreach my $arg(@ARGV){
    $arg=' -'.$arg;
}
(@ARG_COPY)=@ARGV;
#print scalar(@ARGV)." ELEMENTS2\n";
=pod
($concat_args)=join(' ',@ARGV);
push(@split_args,split(/ +-+/,$concat_args));
foreach my $argument(@split_args){
	if($argument !~ m/^-/){#make sure to add a hyphen if it is not there
		$argument='-'.$argument;
	}
}
@ARGV=@split_args;
=cut

#print scalar(@ARGV)." ELEMENTS3\n";

$argc=scalar(@ARGV);
#pretty("rec'd>>>",@ARGV,"<<<");
#finish adding functionality where roles are optional
if($argc >1){
#print "\nARGC_YES\n";
    #set variables to NONE
    $dir        = 'NONE';
    $partner    = 'NONE';
    $cc         = 'NONE';
    $uow        = 'NONE';
    $pstart     = 'NONE';
    $pend       = 'NONE';
    $frstart    = 'NONE';
    $frend      = 'NONE';
    $bkstart    = 'NONE';
    $bkend      = 'NONE';
    $ext        = 'NONE';
    $eoc        = 'NONE';
    $roles      = 'NONE';
    $target     = 'NONE';
	$batch		= 'NO';
	$pskip		='false';
    $frskip		='false';
    $bkskip		='false';
    
    
    foreach $argument (@ARGV){
        #        print "\n>>>$argument<<<arg\n";
        if($argument =~ m/-+(help)/){
            showManualHelp();
            exit;
        }
        if($argument =~ m/-+(version)/){
            showVersion();
            exit;
        }
        elsif($argument =~ m/^\s*\-+partner/ig){# partner id
            (undef,$partner) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+partsep/ig){ #separator between partnerID and collectioncode
            (undef,$partsep) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+(collection_code|cc)/ig){
            (undef,$cc) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+partsep/ig){ #separator between partnerID and collectioncode
            (undef,$partsep) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+(Unit_Of_Work|uow)/ig){
            (undef,$uow) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+(minUOW)/ig){
            (undef,$minUOW) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+(maxUOW)/ig){
            (undef,$maxUOW) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+partsep/ig){ #separator between partnerID and collectioncode
            (undef,$partsep) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+(paginated_Start|pstart)/ig){
			(undef,$pstart) = split(/\=+/,$argument);
			if($pstart=~m/NOT_APPLICABLE/){
				$pskip='true';
			}
		}
        elsif($argument =~ m/^\s*\-+(paginated_End|pend)/ig){
			(undef,$pend) = split(/\=+/,$argument);
			if($pend=~m/NOT_APPLICABLE/){
				$pskip='true';
			}
        }
        elsif($argument =~ m/^\s*\-+(frontmatter_Start|frstart)/ig){
            (undef,$frstart) = split(/\=+/,$argument);
			if($frstart=~m/NOT_APPLICABLE/){
				$frskip='true';
			}
        }
        elsif($argument =~ m/^\s*\-+(frontmatter_End|frend)/ig){
            (undef,$frend) = split(/\=+/,$argument);
			if($frend=~m/NOT_APPLICABLE/){
				$frskip='true';
			}
        }
        elsif($argument =~ m/^\s*\-+(backmatter_Start|bkstart)/ig){
            (undef,$bkstart) = split(/\=+/,$argument);
			if($bkstart=~m/NOT_APPLICABLE/){
				$bkskip='true';
			}
        }
        elsif($argument =~ m/^\s*\-+(backmatter_End|bkend)/ig){
            (undef,$bkend) = split(/\=+/,$argument);
			if($bkend=~m/NOT_APPLICABLE/){
				$bkskip='true';
			}
        }
        elsif($argument =~ m/^\s*\-+partsep/ig){ #separator between partnerID and collectioncode
            (undef,$partsep) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+role/ig){#m d s t de dr se sr separated by forwardslash
            (undef,$roleStr) = split(/\=+/,$argument);
            (@roles)=split(/\//,$roleStr);#list of roles
            undef($roleStr);
            $rolec=scalar(@roles);#role count
        }
        elsif($argument =~ m/^\s*\-+(extension|ext)/ig){
            (undef,$ext) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+target/ig){
            (undef,$target) = split(/\=+/,$argument);
			if($target =~ m/skip_target/){
				$skip_target=1;
				$target='';
			}else{
				$skip_target=0; #do not skip target, default value
			}
        }
        
        elsif($argument =~ m/^\s*\-+eoc/ig){
            (undef,$eoc) = split(/\=+/,$argument);
			if($eoc =~ m/skip_eoc/){
				$skip_EOC=1;
				$eoc='';
			}else{
				$skip_EOC=0;# donot skip eoc, default value\\
			}
        }
        elsif($argument =~ m/^\s*\-+(directory|dir)/ig){
            (undef,$dir) = split(/\=+/,$argument);
			$dir=$dir;
			#print"\ndirectory>>>$dir<<<";
        }
		elsif($argument =~ m/^\s*\-+(insert)/ig){
			push(@inserts,$argument);
        }
        elsif($argument =~ m/^\s*\-+(oversized|ovr)/ig){
			push(@oversized,$argument);
        }
		elsif($argument =~ m/^\s*\-+(hyphen)/ig){
			(undef,$hyphen) = split(/\=+/,$argument);
        }
		elsif($argument =~ m/^\s*\-+(batch)/ig){
			(undef,$batch) = split(/\=+/,$argument);
        }
		elsif($argument =~ m/^\s*\-+(empty)/ig){
			(undef,$empty) = split(/\=+/,$argument);
			if($empty =~ m/true/i){
				push(@empty,'THIS FOLDER IS EMPTY');
			}
        }
        elsif($argument =~ m/^\s*\-+(postcard)/ig){
            (undef,$postcard) = split(/\=+/,$argument);
        }
    }
}
else{
    showManualHelp();
    exit;
}

if($dir eq 'NONE'){
	print "\nDIRECTORY ERROR!\n\tPlease check that the directory exists!\n\tIf you have selected the bagged option, make sure that the data subfolder exists.\n";
	foreach my $argument(@ARG_COPY){
		print $argument." ";
	}
}

#print"\nHYPHENVAL>>>$hyphen<<<\n";
if($hyphen =~ m/^(\s)*yes/i){
	$fr = '-fr';
}else{
	$fr = '_fr';
}

if($target eq ''){
	if($skip_target==0){
		push(@missing,'target');
	}
}

if($eoc eq ''){
	if($skip_EOC==0){
	#print"skipEOC>>$skip_eoc<<<";
		push(@missing,'EOC.csv');
	}
}


#print "\n>>>$ext<<<ext\n";
#print"-dir=$CHECK_FOLDER -partner=$partner_id -cc=$collection_code -uow=$uow -pstart=$MIN_page_id -pend=$MAX_page_id -frstart=$MIN_front_matter -frend=$MAX_front_matter -bkstart=$MIN_back_matter -bkend=$MAX_back_matter -roles=$roles -ext=$extension -eoc=$EOC -target=$target";

#print"\n\tPARID0>>>$partner<<<";
#pretty("\tISRT>>>",@inserts,"<<<");
@files = getVisibleFiles($dir);
#pretty("FILES>>>",@files,"<<<");
@subfolders = getSubfolders($dir);
#pretty("SUBFOLDERS>>>",@subfolders,"<<<");
@hiddenfiles= getHiddenFiles($dir);
#pretty("HIDDENFILE>>>",@hiddenfiles,"<<<");

(@insertNames) 		= makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeInsertNames(@inserts)));
#pretty("INSERTNAMES>>>",makeInsertNames(@inserts),"<<<INSERTNAMES");
#pretty(makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeInsertNames(@inserts))));
(@oversizedNames) 	= makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeOversizedNames(@oversized)));
#pretty(makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeOversizedNames(@oversized))));

if($pskip eq 'false'){
	(@paginatedNames) 	= makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makePaginatedNames(@ARGV)));
}
if($frskip eq 'false'){
	(@frontMatterNames) = makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeFrontMatterNames(@ARGV)));
}
if($bkskip eq 'false'){
	(@backMatterNames)	= makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeBackMatterNames(@ARGV)));
}
(@targetNames)		= makeNameWithExtension(@ARGV,makeTargetNames(@ARGV));
#pretty("\tOVRMD>>>",@oversizedNames,"\t<<<");


if($postcard=~ m/true/i){#make a valid postcard name
    #print "\npostcard>>>is true";
    (@postcards)=makePostcardNames(@ARGV);
}

#=============================== start of questions ===================================
#TO DO: ask the user for the type of delimeter instead of assuming it is an underscore
#When the script fails to extract the information properly, the user can make corrections
#A manual override simply edits the argument string


#print"\nBATCHVAL>>>$batch<<<\n";
if($batch =~ m/no/i){#if batch is no let user interact
	$redo='n';
	#print"\n\tPARID1>>>$partner<<<";
	while($redo=~m/^(\s)*n/i){
		#---this section verifies that the automatic assignation of variables was able to extract the relevant pieces of information,
		#---if the automatic portion failed it will ask the user to input the pertinent data
		print"\n\n";
		#print"\n\tPARID2>>>$partner<<<";
		if($partner =~ m/^(\s)*$/i){# partner id
			$partner=askPartnerID();
			@ARGV=replaceKeyValue('-partner=',$partner,@ARGV);
			#pretty(@ARGV);
		}
		
		if($cc =~ m/^(\s)*$/i){#collection code
			$cc=askCollectionCode();
			@ARGV=replaceKeyValue('-cc=',$cc,@ARGV);
			#pretty(@ARGV);
		}
		
		if($uow !~ m/^(\d)+$/){# unit of work
			$uow=askUOW();
			@ARGV=replaceKeyValue('-uow=',$uow,@ARGV);
			#pretty(@ARGV);
		}
		
		if($pstart !~ m/^(\d)+$/){# paginated page start
			$pstart = askMinPageID();
			$MINPAGEID = $pstart;
			@ARGV=replaceKeyValue('-pstart=',$pstart,@ARGV);
			#pretty(@ARGV);
		}
		
		if($pend !~ m/^(\d)+$/){# paginated page end
			$pend = askMaxPageID();
			$MAX_page = $pend;
			@ARGV=replaceKeyValue('-pend=',$pend,@ARGV);
			#pretty(@ARGV);
		}
		
		if($frend !~ m/^(\d)+$/){#maximum front-matter
			$frend = askMaxFrontMatter();
			@ARGV=replaceKeyValue('-frend=',$frend,@ARGV);
			#pretty(@ARGV);
		}
		 
		if($bkend !~ m/^(\d)+$/){#maximum back-matter
			$bkend = askMaxBackMatter();
			@ARGV=replaceKeyValue('-bkend=',$bkend,@ARGV);
			#pretty(@ARGV);
			
		}
		#NEEDS MORE WORK BELOW
		#------------------------- Roles
		if($rolec < 2){#if there are less than 2 roles 
			(@roles) = askRoles();
			@ARGV=replaceKeyValue('-roles=',join('/',@roles),@ARGV);
		}
		if($roles[0] eq 'THERE SHOULD NOT BE ROLES.'){# allows for a terminal argument to skip this section
			$role = '';
		}
		
		#------------------------- Extension
		if($ext !~ m/^(\s)*\.(\w|\W)+$/i){# extension
			$ext = askExtension();
			@ARGV=replaceKeyValue('-ext=',$ext,@ARGV);
		}
		#------------------------- Target
	
		if ($target eq 'fail, missing target'){# user says there should be an EOC but refuses to enter the name of the file
				$skip_target=1;
				$target='';
		}elsif($target =~ m/^\s*$/){
			$target = askTarget();
			if ($target eq 'fail, missing target'){# user says there should be an EOC but refuses to enter the name of the file
				$skip_target=1;
				$target='';
			}
			if($target eq 'THERE SHOULD NOT BE A TARGET FILE.'){# allows for a terminal argument to skip this section
				$skip_target=1;
			}else{
				$skip_target=0;
			}
		}
		#print "\ntarget>>>$target<<<\n";
		#------------------------- EOC
		
		if($eoc =~ m/^\s*$/){
			$eoc = askEOC();
			@ARGV=replaceKeyValue('-ext=',$eoc,@ARGV);
		}
		
		# allows for a terminal argument to skip this section
		if($eoc eq 'THERE SHOULD NOT BE AN EOC FILE.'){# user says there should not be an EOC file
			$skip_EOC=1;
		}else{
			$skip_EOC=0;#user says there should be an EOC file, and provides the file name (therefore check the name)
			if ($eoc eq 'fail, missing EOC'){# user says there should be an EOC but refuses to enter the name of the file
				push(@missing, 'EOC file');
				$skip_EOC=1; #user just wants to see if
			}
			
		}
		#print "\neoc>>>$eoc<<<\n";
		#Needs more work above    

		#---This is a report on the sample filenames based on the information provided
		print "For roles we will assume m for master and d for derivatives\n";
		#	print "For the extension we will assume .tif for TIFF files\n";
		#	$extension='.tif';
		print "\nSAMPLE FILE NAMES:";

		my @page;
		(@page)=makePaginatedNames(@ARGV);
		(@paginatedNames)=makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,$page[0]));
		foreach my $name(@paginatedNames){
				$name=~s/^-name=//;
				print "\n".$name;
		}
		
		if($skip_target==0){
			(@targetNames) = makeNameWithExtension(@ARGV,makeTargetNames(@ARGV));
			print"\n\nAcceptable target names:";
			foreach my $name(@targetNames){
				$name=~s/^-name=//;
				print "\n\t".$name;
			}
			print "\n";
		}
	
		if($bkend>0){
			my @back;
			(@back)=makeBackMatterNames(@ARGV);
			(@backMatterNames)=makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,$back[0]));
			foreach my $name(@backMatterNames){
				$name=~s/^-name=//;
				print "\n".$name;
				#print $partner."_".$cc.sprintf("%06d",$uow)."_bk".sprintf("%02d",$bkend)."$ext\n";
			}
		}
		if($frend>0){
			my @front;
			(@front)=makeFrontMatterNames(@ARGV);
			(@frontMatterNames)=makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,$front[0]));
			foreach my $name(@frontMatterNames){
				$name=~s/^-name=//;
				print "\n".$name;
				#print $partner."_".$cc.sprintf("%06d",$uow).$fr.sprintf("%02d",$frend)."$ext\n";
			}
		}
		if($skip_EOC==0){
			print "\n$eoc";
		}
		
    
		undef($redo_inner);
		$redo_inner=' ';
		while ($redo_inner !~ m/^(\s)*(y|n)/i){

			if($batch =~ m/^(\s)*n/i){
				print "\nFile names ok? (y for yes, n for no. If not, you will be asked more questions.)\nINPUT>";
				$redo_inner=<STDIN>;#(manual version) leave this line uncommented to have the user manually interact with the program
			}elsif($batch =~ m/^(\s)*y/i){
				$redo_inner='y';#(batch version) leave this line uncommented to have the program run automatically. This line just assumes that everything is OK; that the filename is standard. not recommended.
			}
			$redo=$redo_inner;
			if($redo_inner =~ m/^(\s)*n/i){
				undef($partner);undef($cc);undef($uow);undef($pstart);undef($pend);undef($frend);undef($bkend);
				undef($target);undef($extension);
			}
		}
	}

	(@insertNames) 		= makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeInsertNames(@inserts)));
	#pretty(makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeInsertNames(@inserts))));
	(@oversizedNames) 	= makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeOversizedNames(@oversized)));
	#pretty(makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeOversizedNames(@oversized))));
	if($pskip eq 'false'){
		(@paginatedNames) 	= makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makePaginatedNames(@ARGV)));
	}
	if($frskip eq 'false'){
		(@frontMatterNames) = makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeFrontMatterNames(@ARGV)));
	}
	if($bkskip eq 'false'){
		(@backMatterNames)	= makeNameWithExtension(@ARGV,makeNameWithRole(@ARGV,makeBackMatterNames(@ARGV)));
	}
	(@targetNames)		= makeNameWithExtension(@ARGV,makeTargetNames(@ARGV));
	#pretty("\tOVRMD>>>",@oversizedNames,"\t<<<");

}

#===================================== end of questions =================================
#==================START OF FILENAME CHECK=====================
for(my $i=0;$i<=scalar(@files);$i++){
	$fhash{$files[$i]}='failure of name: ';#files fail by default
  #  $fhash{'target'}='fail, target';
}
#=pod

foreach my $insertMD(@insertNames){
	$insertMD=~s/^-name=//i;
	#pretty("\tIMD>>>".$insertMD."<<<");
	if(exists $fhash{$insertMD}){
		$fhash{$insertMD}='pass, insert ';
	}else{
		$fhash{$insertMD}='fail, missing ';#files fail by default
	}
}
#=cut
#=pod
foreach my $insertMD(@oversizedNames){
	$insertMD=~s/^-name=//i;
	#print"\nOVRSCHK>>>$insertMD<<<";
	if(exists $fhash{$insertMD}){
		$fhash{$insertMD}='pass, oversized ';
	}else{
		$fhash{$insertMD}='fail, missing ';#files fail by default
	}
}
#=cut

foreach my $insertMD(@paginatedNames){#check paginated
	$insertMD=~s/^-name=//i;
	#print"\nPCHK>>>$insertMD<<<";
	#push(@AUTO_NAME,$insertMD);
	if(exists $fhash{$insertMD}){
		$fhash{$insertMD}='pass, paginated ';
	}else{
		$fhash{$insertMD}='fail, missing ';#files fail by default
	}
}
foreach my $insertMD(@frontMatterNames){#check front matter
	$insertMD=~s/^-name=//i;
	#print"\nFRCHK>>>$insertMD<<<";
	if(exists $fhash{$insertMD}){
		$fhash{$insertMD}='pass, front matter ';
	}else{
		$fhash{$insertMD}='fail, missing ';#files fail by default
	}
}
foreach my $insertMD(@backMatterNames){#check back matter
	$insertMD=~s/^-name=//i;
	#print"\nBKCHK>>>$insertMD<<<";
	if(exists $fhash{$insertMD}){
		$fhash{$insertMD}='pass, back matter ';
	}else{
		$fhash{$insertMD}='fail, missing ';#files fail by default
	}
}

foreach my $insertMD(@postcards){#check paginated
	$insertMD=~s/^-name=//i;
	#print"\nPCHK>>>$insertMD<<<";
	#push(@AUTO_NAME,$insertMD);
	if(exists $fhash{$insertMD}){
		$fhash{$insertMD}='pass, ppostcard ';
	}else{
		$fhash{$insertMD}='fail, missing ';#files fail by default
	}
}

foreach my $insertMD(@targetNames){#check target
	$insertMD=~s/^-name=//i;
	#print"\nTARGETCHK>>>$insertMD<<<";
	if(exists $fhash{$insertMD}){
		$fhash{$insertMD}='pass, target name';#if one of the proper names passes, then they all pass
	}
}

my @README_KEYS;
(@README_KEYS)=keys(%fhash);
foreach my $KEY (@README_KEYS){
    if($KEY =~ m/readme.txt$/i){
        $fhash{$KEY}='pass, readme name';#if one of the proper names passes, then they all pass
        #the information printed here displays between the 'SUMMARY OF FEATURES' report and the PASS/FAIL
        

    
        my $directory_path; my @FILE_DATA;
        $directory_path = shift;
        #print"directory_path\n\n>>>$directory_path<<<\n\n";
        #get non-hidden filenames
        open(READMEFH,"<",$dir.'/'.$KEY) || die "can't open $directory_path because $!";
        @FILE_DATA=<READMEFH>;
        close $READMEFH;
        $fDATA=join(' ',@FILE_DATA);
        $fDATA=~s/(\r|\n)+/\n\t\t/g;

        
        print"\t\tFound A readme File!";
        if($fDATA=~m/missing/i){#find the keyword 'missing'
            print"\n\n\t\t$fDATA";
            print"\n\n\t\t END OF the file named: $KEY";
        }
        #print"\nREADMECHK>>>$insertMD<<<";
    }
}

foreach my$key(keys %fhash){
	if($key =~ m/target/i){
		if($skip_target==1){
			$fhash{$key}='failure of name: ';#if there should not be a target but a target is found, ERROR
		}
	}
}

 #---check compliance of file sizes
        #master file size
#error wot 
@ALL_NAMES=(@insertNames,@oversizedNames,@paginatedNames,@frontMatterNames,@backMatterNames);
$ALL_NAMES_count=scalar(@ALL_NAMES);
foreach my $name(@ALL_NAMES){#for the file names that do contain a master file and a derivative file
	my $baseName = removeRole(removeExtension($name));

	my $master=$dir."/".$baseName.'_m'.$ext;
	my $deriv =$dir."/".$baseName.'_d'.$ext;
	
	#print"\nCHECKMASTER>>>".$master."<<<";
	#print"\n\tCHECKDERIV>>>".$deriv."<<<";

    my $result = checkMasterFileSize($master, $deriv);#passes or fails the file
	#print "\n\tOK>>>".checkMasterFileSize($master, $deriv)."<<<";#passes or fails the file

	if($result =~ m/fail, empty master file/i){
        push(@empty,$master);
    }if($result =~ m/fail, empty deriv file/i){
        push(@empty,$deriv);
    }elsif($result =~ m/fail, master file smaller than derivative file/i){
		push(@msmaller,$master);
    }elsif($result =~ m/fail, derivative & master have same size/){
		push(@samesize,$master);
		push(@samesize,$deriv);

    }else{
        #$message = 'pass, master size';
    }
}

if($skip_EOC ==0){ #there should be an EOC file, does not care about the name, except it must end with eoc.csv
    #Is the EOC included?
    if($eoc eq ''){
        $fhash{'EOC.csv'}='fail, missing EOC.csv';#eoc does not exist, create an entry
    }else{
        $fhash{$eoc}='pass, EOC.csv';# eoc exists change value to pass
    }
}

#other folders within folder?
if(scalar(@subfolders) == 0){# if there are no subfolders
    $fhash{'folder'}='pass, folder within folder';
}else{
    foreach $_ (@subfolders){ #if there are subfolders
        $fhash{$_}='fail, folder within folder';  #create an entry inthe fhash hash with the key set to the subfolder name
    }
}


#check if there are hidden files within folder
if(scalar(@hiddenfiles) == 0){#if there are no hidden files
    $fhash{'hiddenfile'}='pass, hidden within folder';
}else{
    foreach$_(@hiddenfiles){# if there are hidden files
        $fhash{$_}='fail, hidden file(s) within this folder' unless $_=~ /\.DS_Store/; # an exception for the .DS_Store file on macintosh computers
    }
}
#==================END FILENAME CHECK=====================


for $key (keys %fhash){
    #go through the fhash hash and sort each failure type such that a given array (such as @hidden for hidden files) only contains one type of error.
    $value = $fhash{$key};
    unless($key=~m/^(\s)*$/){;
        if($value =~m/^fail/){
            if($value =~m/^fail, missing/){
				push(@missing,$key);
				@missing=sort(@missing);
            }
            
            elsif($value =~m/^failure of name/){# does not match a standard filename
                push(@badnames,$key);
                @badnames=sort(@badnames);
            }
            
            elsif($value =~m/^fail, hidden/){#hidden files
                push(@hidden,$key);
                @hidden=sort(@hidden);
            }
            
            #file size issues, same size
            elsif($value =~m/^fail, derivative &/){
                push(@samesize,$key);
                @samesize=sort(@samesize);
            }
            #file size issues
            elsif($value =~m/^fail, derivative file larger/){
                push(@dlarger,$key);
                @dlarger=sort(@dlarger);
            }
            #file size issues
            elsif($value =~m/^fail, master file smaller/){
                push(@msmaller,$key);
                @msmaller=sort(@msmaller);
            }
            
            elsif($value =~m/^fail, folder/){
                push(@badfolder,$key);
                @badfolder=sort(@badfolder);
            }
        }
    }
}

if($target =~ m/^(\s)*n/i){# check the vaule of the target variable
	if($skip_target != 1){
		push(@missing, 'target');
	}
}

(@badfolder)=sort(unique(@badfolder));
(@missing)=sort(unique(@missing));
(@hidden)=sort(unique(@hidden));
(@samesize)=sort(unique(@samesize));
(@dlarger)=sort(unique(@dlarger));
(@msmaller)=sort(unique(@msmaller));
(@empty)=sort(unique(@empty));
(@badnames)=sort(unique(@badnames));

#let the first element of the perl array explain what the rest of the array contains
unshift(@badfolder,'fail, found subfolder(s) within this folder:');# folder present that should not be there
unshift(@missing,'fail, missing:');# missing files
unshift(@hidden,'fail, found hidden file(s) within this folder:');# hidden files that should not be there
unshift(@samesize,'fail, derivative & master have same size:');
unshift(@dlarger,'fail, derivative file larger than master file:');
unshift(@msmaller,'fail, master file smaller than derivative file:');
unshift(@empty,'fail, empty file:');
unshift(@badnames,'fail, file name does not follow naming convention:'); # file name does not follow convention

#create a string of the contents for each perl array, where the array is a container for the errors found
$missingstring=join("\n\t",@missing);
$hiddenstring=join("\n\t",@hidden);
$samesizestring=join("\n\t",@samesize);
$dlargerstring=join("\n\t",@dlarger);
$msmallerstring=join("\n\t",@msmaller);
$badnamesstring=join("\n\t",@badnames);
$badfolderstring=join("\n\t",@badfolder);
$empty=join("\n\t",@empty);

#collect all of the error types in the @Errors array
if((scalar(@missing)-1)>0){
    push(@Errors,$missingstring);
}
if((scalar(@hidden)-1)>0){
    push(@Errors,$hiddenstring);
}
if((scalar(@samesize)-1)>0){
    push(@Errors,$samesizestring);
}
if((scalar(@dlarger)-1)>0){
    push(@Errors,$dlargerstring);
}
if((scalar(@msmaller)-1)>0){
    push(@Errors,$msmallerstring);
}
if((scalar(@badnames)-1)>0){
    push(@Errors,$badnamesstring);
}
if((scalar(@badfolder)-1)>0){
    push(@Errors,$badfolderstring);
}
if((scalar(@empty)-1)>0){
    push(@Errors,$empty);
}


#print "\n>>>$target\n>>>$proper_target_name\n>>>$proper_target_name\n>>>$target\n";
if(scalar(@Errors)!=0){
    fail();
    print "\n\n";
    foreach(@Errors){
        if($_ =~ m/^fail/ig){
            print "$_\n\n";
        }
    }
    endfail();
}else{
    pass();
}

#==========================================================================================================================
#subroutines



sub askCollectionCode{
    #About: asks the user for a Collection Code
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askCollectionCode();
    #Dependencies: none
    my $collection_code;
    print "\nwhat is the collection code?\nINPUT>";
    $collection_code=<STDIN>;
    $collection_code=~s/(\s)+//g;
    return $collection_code;
}

sub askExtension{
    #About: asks the user for the extension
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askExtension();
    #Dependencies: none
    my $extension;
    print "\nWhat is the extension? (examples: .tif .jpg)\nINPUT>";
    $extension=<STDIN>;
    $extension=~s/(\s)+//g;
    return $extension;
}

sub askEOC{
    #About: asks the user if there should be an EOC file
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askEOC();
    #Dependencies: none
    my $EOC;
    print "\nShould there be an EOC file? (y for yes, n for no)\nINPUT>";
    $EOC=<STDIN>;
    if($EOC =~m/^\s*y/i){
        print "Would you like to type the name of the EOC file?\nINPUT>";
        $EOC=<STDIN>;
        if($EOC =~ m/^\s*n/i){
            return "fail, missing EOC";
        }
        else{
            print "Please type in the name of the EOC file.\nINPUT>";
            $EOC=<STDIN>;
            $EOC =~ (s/(\r|\n)$//);
            return $EOC;
        }
    }elsif($EOC =~m/^\s*n/i){
        return 'THERE SHOULD NOT BE AN EOC FILE.';
    }else{
        return '';
    }
}

sub askMinPageID{
    #About: asks the user for a Minimum page number for the paginated pages
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askMinPageID();
    #Dependencies: none
    my $MIN_page_id;
    print "\nwhat is the minimum page id number? (number)\nINPUT>";
    $MIN_page_id=<STDIN>;#
    $MIN_page_id=~s/(\s)+//g;
    $MIN_page_id=$MIN_page_id+0;
    return $MIN_page_id;
}
sub askMaxPageID{
    #About: asks the user for a Maximum page number for the paginated pages
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askMaxPageID();
    #Dependencies: none
    my $MAX_page_id;
    print "\nwhat is the maximum page id number? (number)\nINPUT>";
    $MAX_page_id=<STDIN>;#
    $MAX_page_id=~s/(\s)+//g;
    $MAX_page_id=$MAX_page_id+0;
    return $MAX_page_id;
}
sub askMaxBackMatter{
    #About: asks the user for a Maximum page number for the Back Matter pages
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askMaxBackMatter();
    #Dependencies: none
    my $MAX_back_matter;
    print "\nHow many pages of back matter are there? (number)\nINPUT>";
    $MAX_back_matter=<STDIN>;#
    $MAX_back_matter=~s/(\s)+//g;
    $MAX_back_matter=$MAX_back_matter+0;
    return $MAX_back_matter;
}

sub askMaxFrontMatter{
    #About: asks the user for a Maximum page number for the Front Matter pages
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askMaxFrontMatter();
    #Dependencies: none
    my $MAX_front_matter;
    print "\nHow many pages of front matter are there? (number)\nINPUT>";
    $MAX_front_matter=<STDIN>;#
    $MAX_front_matter=~s/(\s)+//g;
    $MAX_front_matter=$MAX_front_matter+0;
    return $MAX_front_matter;
}

sub askPartnerID{
    #About: asks the user for a ParnerID
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askPartnerID();
    #Dependencies: none
    my $partner_id;
    print "\nWhat is the Partner ID?\n";
    $partner_id=<STDIN>;
    $partner_id=~s/(\s)+//g;
    return $partner_id;
} 

sub askRoles{
    #About: asks the user if there should be more roles
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askRoles();
    #Dependencies: none
    my $role;
    my @roles;
    print "\nShould there be more roles? (y for yes, n for no)\nINPUT>";
    $role=<STDIN>;
    if($role =~m/^\s*y/i){
        print "Please type in the roles there should be separated by a forward slash '/'. Example: m/d\nINPUT>";
        $role=<STDIN>;
        $role =~ s/\s*//g;
        $role =~ (s/(\r|\n)$//);
        (@roles)=split(/\//,$role);
        return @roles;
    }elsif($EOC =~m/^\s*n/i){
        push(@roles,'THERE SHOULD NOT BE ROLES.');
        return(@roles);
    }else{
        return '';
    }
} 

sub askUOW{
    #About: asks the user for a Unit of Work (UOW)
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askUOW();
    #Dependencies: none
    my $uow;
    print "\nwhat is the unit of work? (number)\nINPUT>";
    $uow=<STDIN>;#
    $uow=~s/(\s)+//g;
    $uow=$uow+0;
    return $uow;
}

sub askTarget{
    #About: asks the user if there is a target
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askTarget();
    #Dependencies: none
    my $target;
    print "\nShould there be a target? (y for yes, n for no)\nINPUT>";#should there be a target
    $target=<STDIN>;
    if($target =~m/^\s*y/i){
		 print "Would you like to type the name of the target file?\nINPUT>";#type in the name
        $EOC=<STDIN>;
        if($EOC =~ m/^\s*n/i){#user refuses to type in name
            return "fail, missing target";
        }else{
			print "Please type in the name of the target file.\nINPUT>";# user would like to type in name
			$target=<STDIN>;
			$target =~ (s/(\r|\n)+$//);
			return $target;
		}
    }elsif($target =~m/^\s*n/i){
        return 'THERE SHOULD NOT BE A TARGET FILE.';
    }else{
        return '';
    }
}


sub checkMasterFileSize{
    #About: Checks master and derivative file sizes. Checks that the derivative file is smaller than the master file (cropped). Checks that the master and deriv files are not empty.
    #Input: full path to the properly named master file, full path to the properly named derivative file
    #Output: pass or fail message explaining what went wrong
    #Usage: $output = checkMasterFileSize($path_to_master,$path_to_deriv)
    #Dependencies: none
    
    my $master; my $deriv; my $SIZE_MASTER; my $SIZE_DERIV; my $message;my @args;
    $master=shift; #first argument is the masterfile
    $deriv=shift;
	#(@args)=@_;
    
    
    #---get file sizes
    $SIZE_MASTER=(-s $master);
    $SIZE_DERIV=(-s $deriv);
    
    #master file size
    if($SIZE_MASTER==0){
		if(-e $master){
			$message = 'fail, empty master file';
		}
        
    }elsif($SIZE_DERIV==0){
		if(-e $deriv){
			$message = 'fail, empty deriv file';
		}
        
    }elsif($SIZE_MASTER<$SIZE_DERIV){
        $message = 'fail, master file smaller than derivative file';
        
    }elsif($SIZE_MASTER==$SIZE_DERIV){
        $message = 'fail, derivative & master have same size';
        
    }else{
        $message = 'pass, master size';
    }
    
    return $message;
}

sub deleteKey{
    #About: takes an argument list of -key=value searches for the key portion and if the key portion is found, deletes the -key=value entry
    #Input: -key=value argument list (one entry per array index) and the argument list
    #Output: the argument list (array) without the -key=value entry
    #Usage: (@array_list_without_some_entries)=deleteKey('-key=',@array_list);
    #Dependencies: none
    
			#if argument is -someFlag=someValueHere
			my $key =shift;# this is the -someFlag=
			my@args=@_;# these are all of the arguments
			
			foreach my $pair(@args){
				if($pair =~m/$key/){
					$pair='';
				}
			}
			return @args;
}

sub getCollectionCode{ # Collection123456
    #About: extracts the CollectionCode from the PartID
    #Input: Partner_collection123456
    #Output: collection
    #Usage: $output = getCollectionCode($input)
    #Dependencies: getPartID()
    
    my $PartID; my $CollectionCode;
    $PartID = shift;
    $PartID =~ m/^(\w|\W)+_/;
    $CollectionCode = substr($PartID,$+[0]);#get the postmatched section
    $CollectionCode =~ s/(\d)+//g;
    $CollectionCode =~ s/(_|-)+$//;
    return $CollectionCode;
}

sub getBackMatter{
    #About: extracts the back matter page number from the filename when possible
    #Input: $string filename without extension and without role.
    #$Output: $string containing the back matter page number or returns a space character if filename is not back matter.
    #Usage: $output = getBackMatter($input)
    my $key3; my $key2;
    $key2 = shift;
    $key3 = $key2;
    
    if($key3=~m/(\d)+(_|-)bk(\d)+$/i){
        if($key2=~m/(\d)+$/){
            $back_matter=substr($key2, $-[0], $+[0]-$-[0]); #get the matched sequence
            $back_matter=$back_matter+0;
            return $back_matter;
        }
    }else{
        return ' ';
    }
}

sub getExtension{
    #About: extracts the characters after a "." character, including the dot: for example: abc.txt --> .txt
    #Input: abc.tiff
    #$Output: .tiff
    #Usage: $output = getExtension($input)
    my $string; my $key;
    $key = shift;
    if($key=~m/\.(\w|\W)+$/){
        $string=substr($key, $-[0], $+[0]-$-[0]); # extract the matched sequence for the extension
    }
    return $string;
}

sub getFrontMatter{
    #About: extracts the front matter page number from the filename when possible
    #Input: $string filename without extension and without role.
    #$Output: $string containing the front matter page number or returns a space character if filename is not front matter.
    #Usage: $output = getFrontMatter($input)
    my $key3; my $key2;
    $key2 = shift;
    $key3 = $key2;
    
    if($key3=~m/(\d)+(_|-)fr(\d)+$/i){
        if($key2=~m/(\d)+$/){
            $front_matter=substr($key2, $-[0], $+[0]-$-[0]); #get the matched sequence
            $front_matter=$front_matter+0;
            return $front_matter;
        }
    }else{
        return ' ';
    }
}

sub getInserts{
    #About: checks if a given name follows the insert naming convention, if true returns name else returns an empty string ''
    #Input: $string unmodified filename. Some examples: (not full list)
    #Partner_Collection123456_123456_12_12_m.tif or
    #Partner_Collection123456_123456_12_m.tif or
    #Partner_Collection123456_123456_m.tif
    #Output: $string
    #Usage: $output = getInserts($input_no_ext_no_role,$input_unmodified)
    #Dependencies: removeExtension(); removeRole();
    my $key2; my $key3; my $insert; my $back_matter; my $front_matter;
    $key2=shift; # the unmodified filename
    $key3 = $key2; # the modified filename
    $key3 = removeExtension($key3);
    $key3 = removeRole($key3);
    
    #print "\nkey3axxyy>>>$key3\n";
    #undef($front_matter); undef($back_matter);

    if($key3=~m/(\D)+(\d)+(_|-)fr(\d)+(_|-)(\d+)$/){#front matter insert file name
        $insert = $key2;
    }
    
    elsif($key3=~m/(\D)+(\d)+(_|-)bk(\d)+(_|-)(\d+)$/){#back matter insert file name
        $insert = $key2;
    }
	
	elsif($key3=~m/(\D)+(\d)+(_|-)(\d){6}(_|-)(\d)+$/){#paginated insert mm file name
        $insert = $key2;
    }
    else{
        $insert = '';# not paginated
    }
	#print $insert;
    return $insert;
}

sub getHiddenFiles{
    #About: returns a list of subdirectory names
    #Input: full path to the directory whose contents are to be listed
    #Output: list of subdirectories inside the directory being checked
    #Usage: $output = getHiddenFiles(Input)
    #Dependencies: none
    
    my @hiddenfiles; my $directory_path;
    $directory_path = shift;
    #get all hidden filenames
    opendir(my $DH, $directory_path) || die "can't open $directory_path $!";
    (@hiddenfiles) = grep {!/^(\.)+$/ && /^(\.)+/ && -f "$directory_path/$_"} readdir($DH); # all hidden files except (. ..) etc
    closedir $DH;
    
    return @hiddenfiles;
}

sub getPageID{
    #About: extracts the paginated page from a filename without an extension, without a role, without the oversized _xx or _xx_yy character sequence if applicable. Otherwise returns a space character.
    #Input: string_123456
    #Output: 123456
    #Usage: $output = getPageID($input)
    
    my $key2; my $PageID;
    $key2 = shift;
    if($key2=~m/(_|-)+(\d)+$/){
        #print "PageID matched";
        $PageID=substr($key2, $-[0], $+[0]-$-[0]); #extract matched substring
        $PageID=~s/^(_|-)+//;
        $PageID=~s/(_|-)+$//;
        $PageID=$PageID+0;
        $key2=~s/(_|-)(\d)+$//;
        $PageID=$PageID+0;
        return $PageID;
    }else{
        return ' ';
    }
    
}

sub getPartID{
    #About: creates a PartID from the filename
    #Input: $string filename without extension and without role. examples: Partner_Collection123456_123456_12_12 or Partner_Collection123456_123456_12 or Partner_Collection123456_123456
    #$Output: $string containing the PartID example: Partner_Collection123456
    #Usage: $output = getPartID($input)
    #Dependencies: removeOversizedXXYY(); removeOversizedXX(); removePageID();
    my $key2; my $key3; my $PartID; my $back_matter; my $front_matter;
    $key2=shift;
    $key3=$key2;
    #print "\nkey3axxyy>>>$key3\n";
    #undef($front_matter); undef($back_matter);
    
    if($key3=~m/(\D)(\d)+(_|-)(\d){6}(_|-)(\d)+(_|-)(\d)+$/){#oversized xx yy file name
        
        $key2=removeOversizedXXYY($key2);
        $PartID=$key2;
        #$PartID=~s/(_|-)(\d)+$//; #removes page number
        $PartID = removePageID($PartID);#removes page number
        #$PartID=~s/(\d)+$//;#removes UOW number
        #print"LISTOF>>>$key3<<<";
    }
    
    elsif($key3=~m/(\D)+(\d)+(_|-)(\d){6}(_|-)(\d)+$/){#oversized xx file name
        #print "\nkey3xx>>>$key3\n";
        $key2=removeOversizedXX($key2);
        $PartID=$key2;
        #$PartID=~s/(_|-)(\d)+$//; #removes page number
        $PartID = removePageID($PartID);#removes page number
        #$PartID=~s/(\d)+$//; #removes UOW number
        #print "\nPartID>>>$PartID";
        
        #print"\n\nLISTOF>>>$key3<<<\n\n";
        
    }
    elsif($key3=~m/(\D)+(\d)+(_|-)(\d){6}$/){#regular file name
        
        $PartID=$key2;
        #$PartID=~s/(_|-)(\d)+$//; #removes page number
        $PartID = removePageID($PartID);#removes page number
        #$PartID=~s/(\d)+$//;#removes UOW number
        
    }
    
    elsif($key3=~m/(\D)+(\d)+(_|-)fr(\d)+$/){#front matter file name
        
        $key2=~s/(_|-)fr(\d)+$//; #removes _fr and page number
        #$key2=~s/(\d)+$//;#removes UOW number
        $PartID=$key2;
        
    }elsif($key3=~m/(\D)+(\d)+(_|-)bk(\d)+$/){#back matter file name
        
        $key2=~s/(_|-)bk(\d)+$//;#removes _bk and page number
        #$key2=~s/(\d)+$//;#removes UOW number
        $PartID=$key2;
        
    }
    return $PartID;
}

sub getPartnerID{
    #About: extracts the PartnerID from the PartID
    #Input: Partner_collection123456
    #Output: Partner
    #Usage: $output = getPartnerID($input)
    #Dependencies: getPartID()
    
    my $PartID; my $CollectionCode;
    $PartID = shift;
    $PartID =~ m/^(\w|\W)+_/;
    $PartnerID = substr($PartID,$-[0],$+[0]-$-[0]);#get the matched section
    $PartnerID =~ s/(_|-)+$//;
    return $PartnerID;
}

sub getRole{
    #About: extracts the role of the file. For example _d for derivative, _m for master
    #Input: $string filename without extension
    #$Output: $string containing _m or _d etc.
    #Usage: $output = getRole($input)
    
    my $string; my $role;
    $string =shift;
    if($string=~m/(_|-)(m|d)$/){ #valid roles to seek
        $role=substr($string, $-[0], $+[0]-$-[0]);
    }
    
    return $role;
}

sub getVisibleFiles{
    #About: returns a list of filenames that are not hidden files
    #Input: full path to the directory whose contents are to be listed
    #Output: list of filenames
    #Usage: $output = getVisibleFiles(Input)
    #Dependencies: none
    
    my $directory_path; my @files;
    $directory_path = shift;
	#print"directory_path\n\n>>>$directory_path<<<\n\n";
    #get non-hidden filenames
    opendir(my $DH, $directory_path) || die "can't open $directory_path because $!";
    @files = grep {!/^(\.)+/ && -f "$directory_path/$_"} readdir($DH); # all files that not hidden
    closedir $DH;
    return @files;
}
#garf
sub getSubfolders{
    #About: returns a list of subdirectory names
    #Input: full path to the directory whose contents are to be listed
    #Output: list of subdirectories inside the directory being checked
    #Usage: $output = getSubfolders(Input)
    #Dependencies: none
    
    my @subfolders; my $directory_path;
    $directory_path = shift;
	#print "dirpath>>>$directory_path<<<";
    #get all subfolder names
    opendir(my $DH, $directory_path) || die "can't open $directory_path; $!";
    (@subfolders) = grep {!/^(\.)+$/ && -d "$directory_path/$_"} readdir($DH); # all folders except (. ..) etc
    closedir $DH;
    return @subfolders;
}

sub getUOW{
    # Collection123456
    #About: extracts the Unit of Work number from the PartID
    #Input: Partner_collection123456
    #Output: 123456
    #Usage: $output = getUOW($input)
    #Dependencies: getPartID()
    
    my $PartID; my $CollectionCode;
    $PartID = shift;
    $PartID =~ m/^(\w|\W)+_/;
    $CollectionCode = substr($PartID,$+[0]);#get the postmatched section
    $CollectionCode =~ s/(\D)+//g;
    $CollectionCode =~ s/(_|-)+$//;
    return $CollectionCode;
}

sub makeInsertNames{
    #About: Make file names for inserts
    #Input: Array form of the argument list from RS2017_autoExtract.pl and one flagged argument per array index, where the base file name is preceded by -name=
    #Output: perl array of insert file names without role and without extension
    #Usage: (@array_of_file_names)=makeInsertNames(argument list);
    #Dependencies: none
    
	my @inserts; my @parts; my @names; my $baseName; my $MINmm; my $MAXmm;
	(@inserts)= @_;
	#print pretty("\tINSERT1>>>",@inserts,"\t<<<INSERT1");
	foreach my $element(@inserts){
		@parts=split(/\//,$element);
		foreach my $element(@parts){
            #print "\n\t\tpart>>>$element<<<";
			if($element =~ m/^\s*(-)*insert/){
				$element =~ s/^\s*(-)*insert=//;
				$baseName = $element;
                #print"\nBASENAME>>>$baseName<<<";
			}
			elsif($element =~ m/^MINmm/){
				$element =~ s/^MINmm=//;
				$element =$element+0;
				$MINmm = $element;
			}
			elsif($element =~ m/^MAXmm/){
				$element =~ s/^MAXmm=//;
				$element =$element+0;
				$MAXmm = $element;
			}
		}

			for(my $i=$MINmm;$i<=$MAXmm;$i++){
				#print "\n\tMINmm>>>$baseName>>>$MINmm<<<$MAXmm<<<$i<<<";
				if($MINmm<10){
					$baseName = $baseName.'_'.sprintf("%02d",$i);
				}else{
					$baseName = $baseName.'_'.$i;
				}
				push(@names,'-name='.$baseName);
				$baseName=~ s/_\d+$//;
				#print"\n\tINSERTBASENAME>>>$baseName<<<";
			}
	}
	#print pretty("\tINSERT2>>>",@names,"\t<<<INSERT2");
	return(@names);
}

sub makeMD{
    #About: make master and derivative files for each file name without roles and without extensions
    #Input: Array containing file names
    #Output: perl array of file names with _m and _d as roles and .tif as the extension
    #Usage: (@array_of_file_names)=makeMD(array of file names without role and without extension);
    #Dependencies: none
	my $master; my $deriv; my @names;
	foreach(@_){
		$master = $_."_m.tif";
		$deriv = $_."_d.tif";
		push(@names,$master);
		push(@names,$deriv);
	}
	#pretty("MD>>>",@names,"<<<");
	return(@names);
}

sub makeBackMatterNames{
    #About: make back matter names
    #Input: Array form of the argument list from RS2017_autoExtract.pl and one flagged argument per array index, where the file name is preceded by -name=
    #Output: perl array of backmatter names without role and without extension
    #Usage: (@array_of_file_names)=makeBackMatterNames(argument array);
    #Dependencies: none
    
	my $partner; my $argument; my $cc; my $uow; my $baseName; my @args; my $bkstart; my $bkend; my @names; my $name;
	(@args)=@_;
	$baseName = makeBaseName(@args);
	foreach $argument(@args){
#        print "\n>>>$argument<<<arg\n";


        if($argument =~ m/^\s*\-+(backmatter_Start|bkstart)/ig){
            (undef,$bkstart) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+(backmatter_End|bkend)/ig){
            (undef,$bkend) = split(/\=+/,$argument);
        }      
	}
	
	for(my $i=$bkstart;$i<=$bkend;$i++){
		if($i<10){#add a leading zero
			$name = $baseName.'_'.'bk'.sprintf("%02d",$i);
		}else{
			$name = $baseName.'_'.'bk'.$i;
		}
		push(@names,"-name=".$name);
	}
	return(@names);
}

sub makeBaseName{
    #About: make base names (partner id, collection code, unit of work)
    #Input: Array form of the argument list from RS2017_autoExtract.pl and one flagged argument per array index
    #Output: perl array of base names
    #Usage: (@array_of_file_names)=makeBaseName(argument array);
    #Dependencies: none
    
	my $partner; my $argument; my $cc; my $uow;
	foreach $argument(@_){
		#print"\nMBNARG>>>$argument<<<";
        if($argument =~ m/^(\s)*\-+partner/i){# partner id
		#print"\n\t\tMBNARG2>>>$argument<<<";
            (undef,$partner) = split(/\=+/,$argument);
        }

        elsif($argument =~ m/^\s*\-+(collection_code|cc)/i){
            (undef,$cc) = split(/\=+/,$argument);
        }
  
        elsif($argument =~ m/^\s*\-+(Unit_Of_Work|uow)/i){
            (undef,$uow) = split(/\=+/,$argument);
        }
	}
	#print "\nMBNPARTNER>>>".$partner."<<<";
	if($partner ne ''){
		return $partner.'_'.$cc.$uow;
	}else{# if there is no partner
		return $cc.$uow;
	}
}

sub makeFrontMatterNames{
    #About: make front matter file names (without roles and without extensions)
    #Input: Array form of the argument list from RS2017_autoExtract.pl and one flagged argument per array index
    #Output: perl array of valid file names
    #Usage: (@array_of_file_names)=makeFrontMatterNames(argument array);
    #Dependencies: makeBaseName();

	my $partner; my $argument; my $cc; my $uow; my $baseName; my @args; my @names; my $frstart; my $frend; my $name; my $fr;
	(@args)=@_;
	$baseName = makeBaseName(@args);
	foreach $argument(@args){
#        print "\n>>>$argument<<<arg\n";


        if($argument =~ m/^\s*\-+(frontmatter_Start|frstart)/ig){
            (undef,$frstart) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+(frontmatter_End|frend)/ig){
            (undef,$frend) = split(/\=+/,$argument);
        }
		elsif($argument =~ m/^\s*\-+(hyphen)/ig){
            (undef,$hyphen) = split(/\=+/,$argument);
			#print"\nHYPHENVAL>>>$hyphen<<<\n";
			if($hyphen =~ m/^(\s)*yes/i){
				$fr = '-fr';
			}else{
				$fr = '_fr';
			}
        }
   
	}
	
	for(my $i=$frstart;$i<=$frend;$i++){
		if($i<10){#add a leading zero
			$name = $baseName.$fr.sprintf("%02d",$i); #LOOP
		}else{
			$name = $baseName.$fr.$i; #LOOP
		}
		push(@names,"-name=".$name);
	}
	return(@names);
}

sub makeNameWithRole{
    #About: add roles to the file names
    #Input: Array form of the argument list from RS2017_autoExtract.pl and one flagged argument per array index, where the file name is preceded by -name=
    #Output: perl array of valid file names
    #Usage: (@array_of_file_names)=makeNameWithRole(argument array);
    #Dependencies: none

	my @args; my $name; my $argument; my $roleStr; my $rolec; my @names; my $role; my @roles;
	(@args)=@_;
	foreach $argument(@args){
		if($argument =~ m/^\s*\-+role/ig){#m d s t de dr se sr separated by forwardslash
			(undef,$roleStr) = split(/\=+/,$argument);
			(@roles)=split(/\//,$roleStr);#list of roles
			undef($roleStr);
			#$rolec=scalar(@roles);#role count
		}
	}
	#pretty("ROLES>>>",@roles,"<<<");
    if(scalar(@roles)>0){#if there are roles append the role, however, if there are no roles pass the name as is.
        foreach $name (@args){
            if($name =~ m/(-)*name=/i){
                foreach $role(@roles){
                    push(@names, $name.'_'.$role);
                }

            }
        }
    }else{
        foreach $name (@args){
            if($name =~ m/(-)*name=/i){
                push(@names, $name);
            }
        }
    }
    
	return(@names);
}

sub makeNameWithExtension{
    #About: add an extension to the file names
    #Input: Array form of the argument list from RS2017_autoExtract.pl and one flagged argument per array index, where the file name is preceded by -name=
    #Output: perl array of valid file names
    #Usage: (@array_of_file_names)=makeNameWithExtension(argument array);
    #Dependencies: none
    
	my @args; my $name; my $argument; my $extStr; my $rolec; my @names; my $ext; my @extensions;
	(@args)=@_;
	foreach $argument(@args){
		if($argument =~ m/^\s*\-+(extension|ext)/ig){#
			(undef,$extStr) = split(/\=+/,$argument);
			(@extensions)=split(/\//,$extStr);#list of roles
			undef($extStr);
		}
	}
	
	foreach $name (@args){
		if($name =~ m/(-)*name=/){
			foreach $ext(@extensions){
				push(@names, $name.$ext);
			}
		}
	}
	return(@names);
}

sub makeOversizedNames{
    #About: make valid oversized file names, for the purpose of checking the file names
    #Input: Array form of the argument list from RS2017_autoExtract.pl (one flagged argument per array index)
    #Output: perl array of valid paginated names
    #Usage: (@array_of_file_names)=makeOversizedNames(argument array);
    #Dependencies: makeNameWithExtension(), makeNameWithRole()
    
	my @oversized; my @parts; my @names; my $baseName; my $MINmm; my $MAXmm; my $MINnn; my $MAXnn;
	(@oversized)= @_;
	#print pretty("\tOVERSIZED1>>>",@oversized,"\t<<<OVERSIZED1");
	foreach my $element(@oversized){
		@parts=split(/\//,$element);
		foreach my $element(@parts){
			if($element =~ m/^\s*(-)*oversized/){
				$element =~ s/^\s*(-)*oversized=//;
				$baseName = $element;
			}
			elsif($element =~ m/^MINmm/){
				$element =~ s/^MINmm=//;
				$element =$element+0;
				$MINmm = $element;
			}
			elsif($element =~ m/^MAXmm/){
				$element =~ s/^MAXmm=//;
				$element =$element+0;
				$MAXmm = $element;
			}
			elsif($element =~ m/^MINnn/){
				$element =~ s/^MINnn=//;
				$element =$element+0;
				$MINnn = $element;
			}
			elsif($element =~ m/^MAXnn/){
				$element =~ s/^MAXnn=//;
				$element =$element+0;
				$MAXnn = $element;
			}
		}

			for(my $i=$MINmm;$i<=$MAXmm;$i++){
				#print "\n\tMINmm>>>$baseName>>>$MINmm<<<$MAXmm<<<";
				if($MINmm<10){
					$baseName = $baseName.'_'.sprintf("%02d",$i);
				}else{
					$baseName = $baseName.'_'.$i;
				}
				for(my $j=$MINnn;$j<=$MAXnn;$j++){
					#print "\n\tMINnn>>>$baseName>>>$MINnn<<<$MAXnn<<<";
					if($MINnn<10){
						$baseName = $baseName.'_'.sprintf("%02d",$j);
					}else{
						$baseName = $baseName.'_'.$j;
					}
					push(@names,'-name='.$baseName);
					$baseName=~ s/_\d+$//;# remove the _nn to prepare for the next nn
				}
				$baseName=~ s/_\d+$//;# remove the _mm to prepare for the next mm
			}
	}
	#print pretty("\tOVERSIZED2>>>",@names,"\t<<<OVERSIZED2");
	return(@names);
}

sub makePaginatedNames{
    #About: make valid postcard file names, for the purpose of checking the file names
    #Input: Array form of the argument list from RS2017_autoExtract.pl (one flagged argument per array index)
    #Output: perl array of valid paginated names
    #Usage: (@array_of_file_names)=makeBaseName(argument array);
    #Dependencies: makeBaseName()
	my $partner; my $argument; my $cc; my $uow; my $baseName; my $name; my $pstart; my $pend; my @args; my @names;
	(@args)=@_;
	$baseName = makeBaseName(@args);
	foreach $argument(@args){
        #print "\n>>>$argument<<<arg\n";


        if($argument =~ m/^(\s)*\-+(paginated_Start|pstart)/i){
            (undef,$pstart) = split(/\=+/,$argument);
			#print"\n\tMPNPSTART>>>$pstart<<<";
        }
        elsif($argument =~ m/^(\s)*\-+(paginated_End|pend)/i){
            (undef,$pend) = split(/\=+/,$argument);
			#print"\n\tMPNPEND>>>$pend<<<";
        }    
	}
	
	for(my $i=$pstart;$i<=$pend;$i++){
		$name = $baseName.'_'.sprintf("%06d",$i); #LOOP
		#print"\n\tMPNNAME>>>$name<<<";
		push(@names,"-name=".$name);
	}
	return(@names);
}

sub makePostcardNames{
    #About: make valid postcard file names, for the purpose of checking the file names
    #Input: Array form of the argument list from RS2017_autoExtract.pl (one flagged argument per array index)
    #Output: perl array of valid postcard names
    #Usage: (@array_of_file_names)=makePostcardNames(argument array);
    #Dependencies: makeNameWithExtension(), makeNameWithRole()
    
    my @args;
    my $partner; my $argument; my $cc; my $uow; my @postcards;my $minUOW; my $maxUOW;
    my $UOWcount1; my $UOWcount2; my $UOWcount3; my $digits;
    (@args)=@_;
	foreach $argument(@args){
		#print"\nMBNARG>>>$argument<<<";
        if($argument =~ m/^(\s)*\-+partner/i){# partner id
		#print"\n\t\tMBNARG2>>>$argument<<<";
            (undef,$partner) = split(/\=+/,$argument);
        }

        elsif($argument =~ m/^\s*\-+(collection_code|cc)/i){
            (undef,$cc) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^\s*\-+(uow)/i){
            (undef,$uow) = split(/\=+/,$argument);
            my $c=0;
            foreach(split(//,$uow)){
                #$c++
                #print "\nITEM$c >>>$_<<<"
                if($_ ne ''){
                    $c++;
                }
            }
            $UOWcount1=$c;
        }
        elsif($argument =~ m/^\s*\-+(minUOW)/i){
            (undef,$minUOW) = split(/\=+/,$argument);
            #$UOWcount2=scalar(split(//,$minUOW));
            $minUOW=$minUOW+0;
            my $c=0;
            foreach(split(//,$minUOW)){
                #$c++
                #print "\nITEM$c >>>$_<<<"
                if($_ ne ''){
                    $c++;
                }
            }
            $UOWcount2=$c;
            #print "\nmin>>>$minUOW";
        }
        elsif($argument =~ m/^\s*\-+(maxUOW)/i){
            (undef,$maxUOW) = split(/\=+/,$argument);
            #$UOWcount3=scalar(split(//,$maxuow));
            $maxUOW=$maxUOW+0;
            my $c=0;
            foreach(split(//,$maxUOW)){
                #$c++
                #print "\nITEM$c >>>$_<<<"
                if($_ ne ''){
                    $c++;
                }
            }
            $UOWcount3=$c;
            #print "\nmax>>>$maxUOW";
        }
	}

	#print "\nMBNPARTNER>>>".$partner."<<<";
    $digits=max($UOWcount1,$UOWcount2);
    $digits=max($digits,$UOWcount3);
    #print"\ndigits>>>$digits";
   
	if($partner ne ''){
        for(my $i=$minUOW;$i <= $maxUOW;$i++){
            #print "\nif not empty>>>";
		  push(@postcards,'-name='.$partner.'_'.$cc.sprintf('%06d',$i));
        }
	}else{# if there is no partner
        for(my $i=$minUOW;$i <= $maxUOW;$i++){
        #print "\nif empty>>>";
		  push(@postcards,'-name='.$cc.sprintf('%0'.$digits.'d',$i));
        }
	}
    @postcards=makeNameWithExtension(@args,makeNameWithRole(@args,@postcards));
    foreach(@postcards){
        $_=~s/^-name=//i;
    }
    return(@postcards);
}

sub makeReadmeNames{
    #About: make valid readme file names, for the purpose of checking the file names
    #Input: Array form of the argument list from RS2017_autoExtract.pl (one flagged argument per array index)
    #Output: perl array of valid readme names
    #Usage: (@array_of_file_names)=makeReadmeNames(argument array);
    #Dependencies: makeBaseName();
    
	my $partner; my $argument; my $cc; my $uow; my $baseName; my @args; my $bkstart; my $bkend; my @names; my $name;
	(@args)=@_;
	$baseName = makeBaseName(@args);
	
	$name = $baseName.'_readme.txt';
	push(@names,"-name=".$name);
	$name = 'readme.txt';
	push(@names,"-name=".$name);
	
	return(@names);
}

sub makeTargetNames{
    #About: make valid target names, for the purpose of checking the file names
    #Input: Array form of the argument list from RS2017_autoExtract.pl (one flagged argument per array index)
    #Output: perl array of valid names for the target
    #Usage: (@array_of_file_names)=makeTargetNames(argument array);
    #Dependencies: makeBaseName();

	my $partner; my $argument; my $cc; my $uow; my $baseName; my @args; my $bkstart; my $bkend; my @names; my $name;
	(@args)=@_;
	$baseName = makeBaseName(@args);
	
	$name = $baseName.'_target_m';
	push(@names,"-name=".$name);
	$name = $baseName.'_target';
	push(@names,"-name=".$name);
	
	return(@names);
}



sub max{
    #About: returns the maximum number given two numners as input, else returns a space character
    #Input: list of numbers; example: @numbers =(1,2,3);
    #Output: number with the maximum value; example: 3
    #Usage: $output = max(Input)
    #Dependencies: none
    
    my $num1; my $num2; my $result;
    ($num1,$num2)= @_;
    
    #make sure that the inputs are digits, return a space character if not digits
    if($num1 =~ m/\D/i){
        return ' ';
    }
    if($num2 =~ m/\D/i){
        return ' ';
    }
    
    #if empty character return a space character
    if($num1 eq ''){
        return ' ';
    }
    if($num2 eq ''){
        return ' ';
    }
    
    #compare the numbers
    $result= $num1 <=> $num2;
    if ($result == -1){ #num1 is less than $num2
        return $num2;
    }elsif($result == 1){#num1 is greater than $num2
        return $num1;
    }else{# $num1 is equal to $num2
        return $num1;
    }
    
}

sub min{
    #About: returns the minimum number given two numners as input, else returns a space character
    #Input: list of numbers; example: @numbers =(1,2,3);
    #Output: number with the minimum value; example: 1
    #Usage: $output = min(Input)
    #Dependencies: none
    
    my $num1; my $num2; my $result;
    ($num1,$num2)= @_;
    
    #make sure that the inputs are digits, return a space character if not digits
    if($num1 =~ m/\D/i){
        return ' ';
    }
    if($num2 =~ m/\D/i){
        return ' ';
    }
    
    #if empty character return a space character
    if($num1 eq ''){
        return ' ';
    }
    if($num2 eq ''){
        return ' ';
    }
    
    #compare the numbers
    $result= $num1 <=> $num2;
    if ($result == -1){ # $num1 is less than $num2
        return $num1;
    }elsif($result == 1){ # $num1 is greater than num2
        return $num2;
    }else{ # $num1 is equal to $num2
        return $num2;
    }
    
}

sub removePageID{
    #About: removes the paginated page from a filename without an extension, without a role, without the oversized _xx or _xx_yy character sequence if applicable. Otherwise returns a space character.
    #Input: string_123456
    #Output: string
    #Usage: $output = getPageID($input)
    #Dependencies: none
    
    my $key2;
    $key2 = shift;
    $key2=~s/(_|-)(\d)+$//;
    return $key2;
}

sub removeBackMatter{
    #About: removes the back matter page number(_bk00 or -bk00) from the filename when possible
    #Input: $string filename without extension and without role.
    #Output: $string without the back matter page number
    #Usage: $output = removeBackMatter($input)
    #Dependencies: none
    
    my $string;
    $string = shift;
    $string =~ s/(_|-)+$//;
    $string =~ s/(_|-)bk(\d)+$//i;
    return $string;
}

sub removeFrontMatter{
    #About: removes the front matter page number(_fr00 or -fr00) from the filename when possible
    #Input: $string filename without extension and without role.
    #$Output: $string without the front matter page number
    #Usage: $output = removeFrontMatter($input)
    #Dependencies: none
    
    my $string;
    $string = shift;
    $string =~ s/(_|-)+$//;
    $string =~ s/(_|-)fr(\d)+$//i;
    return $string;
}

sub removeOversizedXXYY{
    #TODO: getOversizedXXYY
    #About: removes the _xx_yy sequence from the oversized file's filename if applicable, otherwise returns a space character
    #Input: $string filename without extension, without role
    #Output: $string filename without _xx_yy sequence
    #Usage: $output = removeOversizedXXYY($input)
    #Dependencies: none
    
    my $key2; my $key3;
    $key2=shift;
    $key3=$key2;
    
    if($key3=~m/(\D)+(\d)+(_|-)(\d){6}(_|-)(\d)+(_|-)(\d)+$/){#oversized xx yy file name
        $key2=~s/(_|-)(\d)+$//; #removes _yy
        $key2=~s/(_|-)(\d)+$//; #removes _xx
        return $key2;
    }else{
        return ' ';
    }
}

sub removeOversizedXX{
    #TODO: getOversizedXX
    #About: removes the _xx sequence from the oversized file's filename if applicable, otherwise returns a space character
    #Input: $string filename without extension, without role
    #Output: $string filename without _xx sequence
    #Usage: $output = removeOversizedXX($input)
    #Dependencies: none
    
    my $key2; my $key3;
    $key2=shift;
    $key3=$key2;
    
    if($key3=~m/(\D)+(\d)+(_|-)(\d){6}(_|-)(\d)+$/){#oversized xx file name
        $key2=~s/(_|-)(\d)+$//; #removes _xx
        return $key2;
    }else{
        return ' ';
    }
}




sub removeRole{
    #About: removes the role of the file. For example: roles are _d for derivative, _m for master etc. abc_d --> abc;
    #Input: $string filename without extension
    #$Output: $string without _m or _d
    #Usage: $output = removeRole($input)
    #Dependencies: none
    
    my $string;
    $string = shift;
    $string =~ s/(_|-)+$//;
	#print"\nRR>>>".$string."<<<";
    $string =~ s/(_|-)+[a-z|A-Z|0-9]$//;
	#print"\nRR>>>".$string."<<<\n";
    $string =~ s/(_|-)+$//;
    return $string;
}

sub removeExtension{
    #About: removes the characters after a "." character, including the dot: for example: abc.txt --> abc
    #Input: $string
    #$Output: $string
    #Usage: $output = removeExtension($input)
    #Dependencies: none
    
    my $string;
    $string = shift;
    $string =~ s/\.(\w)+$//;
    return $string;
}

sub replaceKeyValue{
    #About: replaces the value of a key-value pair (not hash)
    #Input: ('-someFlag=','someNewReplacementValue', @Array_of_key_value_pairs)
    #Output: the Array of key-value pairs where every instance of '-someFlag=' had its value 'someValue' replaced with 'someNewReplacementValue'
    #Usage: @OutputArray =replaceKeyValue('-someFlag=','someNewReplacementValue', @Array_of_key_value_pairs)
    #Dependencies: none
    
	#if argument is -someFlag=someValueHere
	my $key =shift;# this is the -someFlag=
	my $value= shift;# this is the someValueHere
	my@args=@_;# these are all of the arguments
	
	foreach my $pair(@args){
		if($pair =~m/$key/){
			$pair=$key.$value;
		}
	}
	return @args;
}

sub force_underscore{
    #purpose: replace hyphens with underscores in a string
    #input: $string
    #output: $string where hyphens have been replaced with underscores
    #usage: $output = force_underscore($input);
    #Dependencies: none
    
    my $force_underscore;
    $force_underscore=shift;
    $force_underscore=$s/\-/\_/g;
    return($force_underscore);
}

sub showHelp{
    #About: show a message to help users use the program
    #Input: none
    #output: the text written below
    #usage: showHelp();
    #Dependencies: none
    
    print "\nTo use this program: type its path into a terminal and then";
    print "\ntype the path of the folder you want to check ";
    print "\nSample: /Path/to/script/Program_Name.pl /Path/to/some/folder\n\n";
}

sub showVersion{
    #About: Show a message when the user wants to obtain version information
    #Input: none;
    #output: the text written below;
    #usage showVersion();
    #Dependencies: none
    
    print "\nVersion 1.3 (NonBatch Hyphen)\n\n";
}

sub fail{
    #purpose: display an ASCII FAIL graphic on the command line, indicating the beginning of the report on what failed.
    #input: void
    #output: prints the fail graphic to STDOUT
    #sample usage: fail();
    #Dependencies: none
    my(@fail);
    push(@fail,' =========================================== ');
    push(@fail,'|                                           |');
    push(@fail,'|      *****    ***     *****     *         |');
    push(@fail,'|      *       ** **      *       *         |');
    push(@fail,'|      ***     *****      *       *         |');
    push(@fail,'|      *       *   *      *       *         |');
    push(@fail,'|      *       *   *    *****     *****     |');
    push(@fail,'|                                           |');
    push(@fail,' =========================================== ');
    
    foreach(@fail){
        $_=~s/\*/#/g;# makes the characters look bolder
    }
    print "\n";
    
    foreach(@fail){
        print $_."\n";#prints to STDOUT
    }
    
}

sub endfail{
    #purpose: display an ASCII FAIL graphic on the command line, indicating the end of the report on what failed.
    #input: void
    #output: prints the fail graphic to STDOUT
    #sample usage: endfail();
    #Dependencies: none
    my(@fail);
    push(@fail,' =========================================== ');
    push(@fail,'|                                           |');
    push(@fail,'|      -  *****    ***     *****     *      |');
    push(@fail,'|     -   *       ** **      *       *      |');
    push(@fail,'|    -    ***     *****      *       *      |');
    push(@fail,'|   -     *       *   *      *       *      |');
    push(@fail,'|  -      *       *   *    *****     *****  |');
    push(@fail,'|                                           |');
    push(@fail,' =========================================== ');
    
    foreach(@fail){
        $_=~s/\*/#/g;# makes the characters look bolder
        $_=~s/-/#/g;# makes the characters look bolder
    }
    print "\n";
    
    foreach(@fail){
        print $_."\n";#prints to STDOUT
    }
    
}

sub pass{
    #purpose: display an ASCII PASS graphic on the command line
    #input: void
    #output: prints the PASS graphic to STDOUT
    #sample usage: pass();
    #Dependencies: none
    my(@pass);
    push(@pass,' ==================================== ');
    push(@pass,'|                                    |');
    push(@pass,'|  ****     ***     ****     ****    |');
    push(@pass,'|  *  **   ** **   **       **       |');
    push(@pass,'|  ****    *****    ****     ****    |');
    push(@pass,'|  *       *   *       **       **   |');
    push(@pass,'|  *       *   *    ****     ****    |');
    push(@pass,'|                                    |');
    push(@pass,' ==================================== ');
    
    foreach(@pass){
        $_=~s/\*/#/g;# makes the characters look bolder
    }
    print "\n";
    
    foreach(@pass){
        print $_."\n";#prints to STDOUT
    }	
}

sub unique{
    #About: return a perl array with unique entries
    #Input: @inputArray
    #Output: @outputArray
    #Usage: (@output)= unique(@inputArray);
    #Dependencies: none
    my %hash;
    foreach(@_){
        $hash{$_} = undef; #set the value of each key to undef
    }
    return keys(%hash);
}

sub getCharCount{
    #About: returns the number of characters in a string
    #Input: string
    #Output: number
    #Usage: $output = getCharCount(Input)
    #Dependencies: none
    
    my $string;
    my @chars;
    $string = shift;
    @chars=split(//,$string);
    
    return(scalar(@chars));
}


sub showManualHelp{
    #About: show the user the options available to tun the script manually
    #Input: none
    #Output: prints to STDOUT the contents below
    #Usage: showManualHelp();
    #Dependencies: none
    print"please substitute <sample field value> for your particular values\n";

    print"\n\n -partner=<partner>                This argument is optional. sets the partner information";

    print"\n\n -collection_code=<collection>     This argument is optional. sets the collection code information";
    print"\n -cc=<collection>                  This argument is optional. Same as -collection_code";

    print"\n\n -unit_of_work=<123456>            This argument is optional. sets the unit of work information";
    print"\n -uow=<123456>                     This argument is optional. Same as -unit_of_work";

    print"\n\n -paginated_start=<0>               This argument is optional. sets the beginning of the paginated pages range";
    print"\n -pstart=<123>                     Same as -paginated_start";

    print"\n\n -paginated_end=<123>               This argument is optional. sets the end of the paginated pages range";
    print"\n -pend=<123>                       Same as -paginated_end";

    print"\n\n -frontmatter_start=<0>             This argument is optional. sets the beginning of the frontmatter pages range";
    print"\n -frstart=<123>                    Same as -frontmatter_start";

    print"\n\n -frontmatter_end=<123>             This argument is optional. sets the end of the frontmatter pages range";
    print"\n -frend=<123>                      Same as -frontmatter_end";

    print"\n\n -backmatter_start=<0>              This argument is optional. sets the beginning of the backmatter pages range";
    print"\n -bkstart=<123>                    Same as -backmatter_start";

    print"\n\n -backmatter_end=<123>              This argument is optional. sets the end of the backmatter pages range";
    print"\n -bkend=<123>                      Same as -frontmatter_end";

    print"\n\n -role=<m>                         This argument is optional. sets the partner information";
    
    print"\n\n -extension=<.tif>                  This argument is optional. sets the partner information";
    print"\n -ext=<.tif>                       Same as -extension.";
    
    print"\n\n -directory=</path/to/dir>     This argument is optional. sets the partner information";
    print"\n -dir=</path/to/dir>            Same as -directory.";
    
    print"\n\n -oversize=<yes/no>                This argument is optional. Checks oversize if yes. Default is yes.";
    print"\n -ovr=<yes/no>                      Same as -oversize.";
}

sub pretty{
	foreach(@_){
		print "\n".$_;
	}
	print "\n";
}

