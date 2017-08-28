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
=cut

#ref names have no padding
#typo @ SIZE_DERIV
$ref=0;#filenames with ref use a different naming scheme


#fix the arguments as they come from the command line
$ARGUMENT_STRING=join(' ',@ARGV);
#print "\nSTRING:$ARGUMENT_STRING\n";
@ARGV=();
(@ARGV)=split(/ +-+/,$ARGUMENT_STRING);
foreach my $arg(@ARGV){
    #$arg=' -'.$arg;
    if($arg =~ m/^(\s)*-+dir(\s)*=(\s)*/i){
        $arg=~s/^(\s)*-+dir(\s)*=(\s)*//i;
    }
    #print "\nARGIS>>$arg<<\n";
}


#if(scalar(@ARGV) == 1){
    #$CHECK_FOLDER=$ARGV[0];
	$CHECK_FOLDER=join(' ',@ARGV);#assume filename is OK

	
    if(($CHECK_FOLDER=~m/^(\s)*(-)+h/i)or($CHECK_FOLDER=~m/^(\s)*\/\?$/i)){
        showHelp();	
        exit;
    }elsif($CHECK_FOLDER=~m/^(\s)*(-)+v/i){
        showVersion();
        exit;
    }else{
        @files = getVisibleFiles($CHECK_FOLDER);
        @subfolders = getSubfolders($CHECK_FOLDER);
        @hiddenfiles= getHiddenFiles($CHECK_FOLDER);
		$fileSize=scalar(@files);
		#print"YOUHAVE>>>$fileSize<<<FILES\n";
		if($fileSize<=0){
			$isEmpty='true';
		}else{
			$isEmpty='false';
		}
    }
#}else{
    #die "You must enter a folder path\n";
#}

#print "\nHello,\nYou are in \n$CHECK_FOLDER/\n\n";#indicates path to folder being checked


for(my $i=0;$i<=scalar(@files);$i++){
	$fhash{$files[$i]}='failure of name: ';#files fail by default
  #  $fhash{'target'}='fail, target';
}

#=================Start of Automatic Assignation of Variables===================

# A PartID is a fragment made from the filenames found in a folder that can be used to identify a unit such as a book. For example: while the pages may change, the name of the book is the same.

for my $key(keys %fPartIDhash_pop){
	$fPartIDhash_pop{$key}=undef;# this hash is used to attempt to choose the most common PartID, the less common PartID's are considered to be due to typos etc.
}




for my $key(keys %fhash){
    my($key2, $PageID, $uow,$ext,$front_matter,$back_matter,$is_d,$PartID);
	undef($key2);undef($PageID);undef($uow);undef($ext);undef($front_matter);undef($back_matter);
    
    $key_target=$key;
	
    $key2=$key;
    $key2=removeExtension($key2);#remove the file extension
	
  
    $is_d=getRole($key2);
	
	#print "\nROLE>>>$is_d<<<";
    push(@ROLES,$is_d) unless($is_d eq '');#collect all of the roles encountered
    $key2=removeRole($key2);# remove the _m or _d file role
	#print "\nNOROLE>>>$key2<<<";
	
	$insertName =getInserts($key2);
	push(@insert, $insertName) unless $insertName eq '';
	
	$oversizedName =getOversized($key2);
	push(@oversizedItems, $oversizedName) unless $oversizedName eq '';

	
	$PartID = getPartID($key2);# create a PartID
	#print "\n\tPARTID>>>$PartID<<<";
	
	if($fPartIDhash_pop{$PartID} eq ''){
		$fPartIDhash_pop{$PartID} =0;
	}
	$fPartIDhash_pop{$PartID}=$fPartIDhash_pop{$PartID}+1;

	$key10 = removeOversizedNN($key2);
	$key2 = $key10 unless $key10 eq ' ';
	undef($key10);
	#print "\n\tNOOVNN>>>$key2<<<";
	
	$key11 = removeOversizedMM($key2);
	$key2 = $key11 unless $key11 eq ' ';
	undef($key11);
	#print "\n\tNOOVMM>>>$key2<<<";
	my $front_matter = 'NOT_APPLICABLE';
	$front_matter = getFrontMatter($key2) unless getFrontMatter($key2) eq ' ';# extract the front matter page number if applicable (else returns a space character)
	#print "\n\tFRON>>>$front_matter<<<";
	
	$key12 = removeFrontMatter($key2);
	$key2 = $key12 unless $key12 eq ' ';
	undef($key12);
	#print "\n\tNOFRON>>>$key2<<<";
    my $back_matter = 'NOT_APPLICABLE';
	$back_matter  = getBackMatter($key2) unless getBackMatter($key2) eq ' ';# extract the back matter page number if applicable (else returns a space character)
	#print "\n\tBACK>>>$back_matter<<<";
	$key13 = removeBackMatter($key2);
	$key2 = $key13 unless $key13 eq ' ';
	undef($key13);
	#print "\n\tNOBACK>>>$key2<<<";
    

    $ext=getExtension($key); # extract the extension
	$fPartIDhash{'ext'.$PartID}=$ext;
	#print "\n\tEXTENS>>>$ext<<<";
    $PageID = 'NOT_APPLICABLE';
    $PageID = getPageID($key2) unless getPageID($key2) eq ' ';# extract the paginated page number if applicable (else returns a space character)
	$key14 = removePageID($key2);
    $key2 = $key14 unless $key14 eq ' ';
	#print "\n\tPAGEID>>>$PageID<<<";
    
    $PartnerID = getPartnerID($PartID);# extract a PartnerID
	#print "\nPARTNE>>>$PartnerID<<<";
    $CollectionCode = getCollectionCode($PartID); #extract a CollectionCode
	#print "\n\tCOLCOD>>>$CollectionCode<<<";
	
    #PartID looks like PID_CC123456
	if ($PartID !~ m/^(\s)*$/){

#BUGGY SECTION
        #------------------------------
		if($front_matter ne 'NOT_APPLICABLE'){
			#get the largest frontmatter page number
				if(($fPartIDhash{'MAXfront'.$PartID} =~m/^(\s)*$/)||($fPartIDhash{'MAXfront'.$PartID} eq undef)){#if there is no page number choose the first valid one
					$fPartIDhash{'MAXfront'.$PartID}=$front_matter+0;
				}else{
                    $fPartIDhash{'MAXfront'.$PartID}=max($front_matter,$fPartIDhash{'MAXfront'.$PartID});#get the maximum page number
                }
				
        
			if(($fPartIDhash{'MINfront'.$PartID} =~m/^(\s)*$/)||($fPartIDhash{'MINfront'.$PartID} eq undef)){# if there is no page number choose the first valid one
					$fPartIDhash{'MINfront'.$PartID}=$front_matter+0;
				}else{
                    $fPartIDhash{'MINfront'.$PartID}=min($front_matter,$fPartIDhash{'MINfront'.$PartID});#get the minimum page number
            }
		}else{
			if($fPartIDhash{'MINfront'.$PartID} eq ''){
				$fPartIDhash{'MINfront'.$PartID} ='NOT_APPLICABLE';
			}
			if($fPartIDhash{'MAXfront'.$PartID} eq ''){
				$fPartIDhash{'MAXfront'.$PartID} ='NOT_APPLICABLE';
			}
		}
		if($back_matter ne 'NOT_APPLICABLE'){
        #get back matter pages
			if(($fPartIDhash{'MAXback'.$PartID} =~m/^(\s)*$/) or ($fPartIDhash{'MAXback'.$PartID} eq undef)){#if there is no page number choose the first valid one
					$fPartIDhash{'MAXback'.$PartID}=$back_matter+0;
				}else{
                    $fPartIDhash{'MAXback'.$PartID}=max($back_matter,$fPartIDhash{'MAXback'.$PartID});#get the maximum page number
                } #get the largest backmatter page number
        
            if(($fPartIDhash{'MINback'.$PartID} =~m/^(\s)*$/) or ($fPartIDhash{'MINback'.$PartID} eq undef)){# if there is no page number choose the first valid one
					$fPartIDhash{'MINback'.$PartID}=$back_matter+0;
				}else{
                    $fPartIDhash{'MINback'.$PartID}=min($back_matter,$fPartIDhash{'MINback'.$PartID});#get the minimum page number
            }
		}else{
			if($fPartIDhash{'MINback'.$PartID} eq ''){
				$fPartIDhash{'MINback'.$PartID} ='NOT_APPLICABLE';
			}
			if($fPartIDhash{'MAXback'.$PartID} eq ''){
				$fPartIDhash{'MAXback'.$PartID} ='NOT_APPLICABLE';
			}
		}
     
        #------------------------------
    
		if(($front_matter=~m/NOT_APPLICABLE/) and ($back_matter=~m/NOT_APPLICABLE/) and ($PageID!~m/NOT_APPLICABLE/)){ #if not front matter or backmatter, the name contains a paginated-page-like number
			#get the minimum and maximum page numbers (of the paginated pages) from the filenames
			#if($key2=~m/(\d)+$/){
                #print" MINMAXpageid>>>$PageID<<<\n";
                #get the maximum paginated page number
				if(($fPartIDhash{'MAXpageID'.$PartID} =~m/^(\s)*$/)||($fPartIDhash{'MAXpageID'.$PartID} eq undef)){#if there is no page number choose the first valid one
					$fPartIDhash{'MAXpageID'.$PartID}=$PageID+0;
				}else{
                    $fPartIDhash{'MAXpageID'.$PartID}=max($PageID,$fPartIDhash{'MAXpageID'.$PartID});#get the maximum page number
                }
                
                #get the minimum paginated page number
				if(($fPartIDhash{'MINpageID'.$PartID} =~m/^(\s)*$/)||($fPartIDhash{'MINpageID'.$PartID} eq undef)){# if there is no page number choose the first valid one
					$fPartIDhash{'MINpageID'.$PartID}=$PageID+0;
				}else{
                    $fPartIDhash{'MINpageID'.$PartID}=min($PageID,$fPartIDhash{'MINpageID'.$PartID});#get the minimum page number
                }
                
                #print" f(MIN,MAX)pageid>$PartID>>$fPartIDhash{'MINpageID'.$PartID},$fPartIDhash{'MAXpageID'.$PartID}<<<\n";
			     $key2 = removePageID($key2);
            #}
		}elsif($PageID=~m/NOT_APPLICABLE/){
			if($fPartIDhash{'MAXpageID'.$PartID} eq ''){
				$fPartIDhash{'MAXpageID'.$PartID}='NOT_APPLICABLE';
			}
			if($fPartIDhash{'MINpageID'.$PartID} eq ''){
				$fPartIDhash{'MINpageID'.$PartID}='NOT_APPLICABLE';
			}
		}
        #------------------------------
		#unit of work

		#------------------------------
		#file sizes
        #the purpose of this section is to find out the file sizes of the current files, and to keep a tally of how many files there are
        #in a later section this information is used to calculate the average size of a master file, and the average size of a d file.
        #a large deviation indicates that there might be a problem with the image (cropped master, uncropped derivative etc.)
		if($is_d=~m/d/i){#get d file size information
			$fPartIDhash{'d_count'.$PartID}=$fPartIDhash{'d_count'.$PartID}+1; # counts how many dfiles have gone through
			#regular d size
			$sized=(-s "$CHECK_FOLDER/$key");# get the size of the current d file
			if(($fPartIDhash{'sized'.$PartID}=~m/^(\s)*$/)||($fPartIDhash{'sized'.$PartID}eq undef)){
				$fPartIDhash{'sized'.$PartID}=$sized;
			}else{
				$fPartIDhash{'sized'.$PartID}=int(($fPartIDhash{'sized'.$PartID}+$sized));
			}
		}elsif($is_d=~m/m/i){#get m file size information
			$fPartIDhash{'m_count'.$PartID}=$fPartIDhash{'m_count'.$PartID}+1; # counts how many m files have gone though
			#regular m size
			$sizem=(-s "$CHECK_FOLDER/$key");# get the size of the current m file
			if(($fPartIDhash{'sizem'.$PartID}=~m/^(\s)*$/)||($fPartIDhash{'sized'.$PartID}eq undef)){
				$fPartIDhash{'sizem'.$PartID}=$sizem;
			}else{
				$fPartIDhash{'sizem'.$PartID}=int(($fPartIDhash{'sizem'.$PartID}+$sizem));
			} 
		}

		#------------------------------
		#popularity of PartID
		
		if(($fPartIDhash_pop{$PartID}=~m/^(\s)*$/)||($fPartIDhash_pop{$PartID}eq undef)){
			$fPartIDhash_pop{$PartID}=1; #create a key-value pair of each new PartID encountered and initialize its count to 1;
		}
		
        
		$fPartIDhash_pop{$PartID}=$fPartIDhash_pop{$PartID}+1; #increment the count of the current PartID by 1
        
		$fPartIDhash{'PartnerID'.$PartID}=$PartnerID;#creates an entry for the PartnerID for the current $PartID
		$fPartIDhash{'CollectionCode'.$PartID}=$CollectionCode;#creates an entry for the CollectionCode for the current $PartID
        #if($fPartIDhash{'uow'.$PartID} eq ''){
            if($uow_hash{'min'} eq ''){
                  $fPartIDhash{'uow'.$PartID}=getUOW($PartID);
                  $minUOW=getUOW($PartID);
                  $maxUOW=getUOW($PartID);
                  $uow_hash{'min'}=$minUOW;
                  $uow_hash{'max'}=$maxUOW;
                  #print "run Once";
              }
        #}
        else{
            $UOWPID=getUOW($PartID)+0;
            
            #$UOWPID
            
            $minUOWPID=$minUOW + 0;
            $maxUOWPID=$maxUOW + 0;
            #print "\nUOWPID>>>$UOWPID<<<\n\tMIN>>>$minUOWPID<<<\n\tMAX>>>$maxUOWPID<<<";
            if($minUOWPID > $UOWPID){
              $minUOW=getUOW($PartID);
              #print"\n\tminUOW>>>$minUOW<<<";
            }
            if($maxUOWPID < $UOWPID){
              $maxUOW=getUOW($PartID);
              #print"\n\tmaxUOW>>>$maxUOW<<<";
            }
              
        }
        #------------------------------
	}
	#------------------------------
	#target filename
	if($key=~m/target/i){
		$target_name=$key;

	}
	#------------------------------
	#environment of creation
	if($key=~m/eoc\.csv$/i){
        $EOC=$key;

	}
	#------------------------------
}

#check insert values
#print"\nSO minUOW>>>$minUOW<<<";
#print"\nSO maxUOW>>>$maxUOW<<<";

$old_value=0;
for my $key(keys %fPartIDhash_pop){
my $value;
$value =0;
		#print "\n\tFPIDHP KEY>>>$key<<<";
		#print "\n\tFPIDHP VAL>>>$fPartIDhash_pop{$key}<<<";
    #the value of the key-value pair contains the number of times a given key appeared. The key of the key-value pair contains the unique PartID.
	$value=$fPartIDhash_pop{$key};

	$value=$value+0;
    if($value > $old_value){
        if($value !~ m/(\s)+/){# the value can be no spaces, tabs, etc.
            $PreferredPartID = $key;
			$old_value=$value;
        }
		
    }

}

#print "\nPREF>>>$PreferredPartID<<<\n\n";

#------------------------------§ is bad
#Assign values to the global variables
undef($key);undef($value);undef(@popularity);undef(@popularity2);
$MoreCollectionCodes='no';
$first=1;
for$key(keys %fPartIDhash){

	if($first==1){
		if($key =~ m/CollectionCode/i){
		$old_key=$key;
		$first=0;
		}
	}else{
		if($key =~ m/CollectionCode/i){
			$MoreCollectionCodes='yes' unless $key =~ m/$old_key/i;
			$old_key=$key;
		}
	}
}
#------------------------------ is bad
undef $key;
undef $value;

#find out which is the most common PartID
$old_value=0;
for$key(%fPartIDhash_pop){
    #the value of the key-value pair contains the number of times a given key appeared. The key of the key-value pair contains the unique PartID.
	$value=$fPartIDhash_pop{$key};
    if($value > $old_value){
        if($value !~ m/(\s)+/){# the value can be no spaces, tabs, etc.
            $PreferredPartID = $key;
        }
		$old_value = $value;
    }
}
print "\n";
#------------------------------


#once the most common PartID is found, extract the appropriate partner id, collection code etc. from the fPartIDhash hash
$MAX_front_matter='NOT_APPLICABLE';
$MIN_front_matter='NOT_APPLICABLE';
$MAX_back_matter='NOT_APPLICABLE';
$MIN_back_matter='NOT_APPLICABLE';

$MIN_page_id ='NOT_APPLICABLE';
$MINPAGEID ='NOT_APPLICABLE';
$MAX_page_id='NOT_APPLICABLE';
$MAX_page='NOT_APPLICABLE';

$partner_id       = $fPartIDhash{'PartnerID'.$PreferredPartID};
$collection_code  = $fPartIDhash{'CollectionCode'.$PreferredPartID};
$uow              = $fPartIDhash{'uow'.$PreferredPartID};


$MIN_page_id      = ($fPartIDhash{'MINpageID'.$PreferredPartID})unless $fPartIDhash{'MINpageID'.$PreferredPartID}=~m/NOT_APPLICABLE/;
$MINPAGEID        = ($MIN_page_id+0) unless $fPartIDhash{'MINpageID'.$PreferredPartID}=~m/NOT_APPLICABLE/;
$MAX_page_id      = ($fPartIDhash{'MAXpageID'.$PreferredPartID})unless $fPartIDhash{'MAXpageID'.$PreferredPartID}=~m/NOT_APPLICABLE/;
$MAX_page         = ($MAX_page_id+0) unless $fPartIDhash{'MAXpageID'.$PreferredPartID}=~m/NOT_APPLICABLE/;

$MAX_front_matter = ($fPartIDhash{'MAXfront'.$PreferredPartID}+0)unless $fPartIDhash{'MAXfront'.$PreferredPartID}=~m/NOT_APPLICABLE/;
$MIN_front_matter = ($fPartIDhash{'MINfront'.$PreferredPartID}+0)unless $fPartIDhash{'MAXfront'.$PreferredPartID}=~m/NOT_APPLICABLE/;
$MAX_back_matter  = ($fPartIDhash{'MAXback'.$PreferredPartID}+0)unless $fPartIDhash{'MAXfront'.$PreferredPartID}=~m/NOT_APPLICABLE/;
$MIN_back_matter  = ($fPartIDhash{'MINback'.$PreferredPartID}+0)unless $fPartIDhash{'MAXfront'.$PreferredPartID}=~m/NOT_APPLICABLE/;

$extension        = $fPartIDhash{'ext'.$PreferredPartID};
#------------------------------


# d_count and m_count cannot be zero, 
if($fPartIDhash{'d_count'.$PreferredPartID} =~m/^(\s)*$/){
	$fPartIDhash{'d_count'.$PreferredPartID}=1;
}

if($fPartIDhash{'m_count'.$PreferredPartID} =~m/^(\s)*$/){
	$fPartIDhash{'m_count'.$PreferredPartID}=1;
}

unless($fPartIDhash{'sized'.$PreferredPartID}=~m/^(\s)*$/){
$AVG_SIZE_DERIVS=int(($fPartIDhash{'sized'.$PreferredPartID})/$fPartIDhash{'d_count'.$PreferredPartID});
}

unless($fPartIDhash{'sizem'.$PreferredPartID}=~m/^(\s)*$/){
	$AVG_SIZE_MASTER=int(($fPartIDhash{'sizem'.$PreferredPartID})/$fPartIDhash{'m_count'.$PreferredPartID});
}

@Roles=unique(@ROLES);#get the unique roles
undef(@ROLES);
$roles=join('/',@Roles);#join the unique roles with a semicolon
undef(@Roles);
#pretty("INSERTS>>>",@insert,"<<<");
	$insertsArgs=getInsertsArgString(@insert);
#pretty("IARG>>>",$insertsArgs,"<<<");
#pretty("OVR>>>",@oversizedItems,"<<<");
	$oversizedArgs=getOversizedArgString(@oversizedItems);
#pretty("OARG>>>",$oversizedArgs,"<<<");

print"-dir=$CHECK_FOLDER -partner=$partner_id -cc=$collection_code -uow=$uow -pstart=$MIN_page_id -pend=$MAX_page_id -frstart=$MIN_front_matter -frend=$MAX_front_matter -bkstart=$MIN_back_matter -bkend=$MAX_back_matter -roles=$roles -ext=$extension -eoc=$EOC -target=$target_name -empty=$isEmpty -minUOW=$minUOW -maxUOW=$maxUOW $insertsArgs $oversizedArgs";
#print"-partner=$partner_id -cc=$collection_code -uow=$uow -pstart=$MIN_page_id -pend=$MAX_page_id -frstart=$MIN_front_matter -frend=$MAX_front_matter -bkstart=$MIN_back_matter -bkend=$MAX_back_matter -ext=$extension -eoc=$EOC -target=$target";

#==========================================================================================================================
#subroutines



sub endfail{
    #purpose: display an ASCII FAIL graphic on the command line, indicating the end of the report on what failed. 
    #input: void
    #output: prints the fail graphic to STDOUT
    #sample usage: endfail();

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

sub fail{
    #purpose: display an ASCII FAIL graphic on the command line, indicating the beginning of the report on what failed. 
    #input: void
    #output: prints the fail graphic to STDOUT
    #sample usage: fail();

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

sub getCollectionCode{ # Collection123456
    #About: extracts the CollectionCode from the PartID
    #Input: Partner_collection123456
    #Output: collection
    #Usage: $output = getCollectionCode($input)
    #Dependency: getPartID()
    
    my $PartID; my $CollectionCode;
    $PartID = shift;
    $PartID =~ s/^\w+(_|-)+//i;
	$PartID =~ s/(\d)+//i;
    $CollectionCode = $PartID;

    return $CollectionCode;
}

sub getExtension{
    #About: extracts the characters after a "." character, including the dot: for example: abc.txt --> .txt
    #Input: abc.tiff
    #$Output: .tiff
    #Usage: $output = getExtension($input)
    my $string; my $key;
    $key = shift;
    if($key=~m/\.(\w|\W)+$/){
			$string=substr($key,$-[0],$+[0]-$-[0]); # extract the matched sequence for the extension
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
			$front_matter=substr($key2,$-[0],$+[0]-$-[0]); #get the matched sequence
			$front_matter=$front_matter+0;
            return $front_matter;
        }
    }else{
        return ' ';
    }
}

sub getHiddenFiles{
    #About: returns a list of subdirectory names
    #Input: full path to the directory whose contents are to be listed
    #Output: list of subdirectories inside the directory being checked
    #Usage: $output = getSubfolders(Input)
    #Dependency: none
    
    my @hiddenfiles; my $directory_path;          
    $directory_path = shift;      
    #get all hidden filenames
    opendir($DH, $directory_path) || die "can't open $directory_path $!";
        @hiddenfiles = grep {!/^(\.)+$/ && /^(\.)+/ && -f "$directory_path/$_"} readdir($DH); # all hidden files except (. ..) etc
    closedir $DH;
    
    return @hiddenfiles;
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
	#print "\n\tGI_INS CHECK>>>".$key2."<<<";
    if($key3=~m/(\D)+(\d)+(_|-)+fr(\d)+(_|-)+(\d+)$/){#front matter insert file name
        $insert = $key2;
		#print "\n\t\tGI_INS FR>>>".$insert."<<<";
    }
    
    elsif($key3=~m/(\D)+(\d)+(_|-)+bk(\d)+(_|-)+(\d+)$/){#back matter insert file name
        $insert = $key2;
		#print "\n\t\tGI_INS BK>>>".$insert."<<<";
    }
	
	elsif($key3=~m/(\D)+(\d)+(_|-)+(\d){6}(_|-)+(\d)+$/i){#paginated insert mm file name BUGGY
        $insert = $key2;
		#print "\n\t\tGI_INS PAG>>>".$insert."<<<";
    }
    else{
        $insert = '';# not insert
		#print "\n\t\tGI_INS NOMATCH>>>".$insert."<<<";
    }
	#print "\n\tGI_INS EXIT>>>".$insert."<<<";
    return $insert;
}

sub getInsertsArgString{
	#About: Produces an argument for oversized file names
    #Input: file names that match the insert names naming convention
    #Output: A string that contains the information necessary to check insert file names (used by RS2017_exist)
    #Usage: getOversizedAargString(@array_of_oversized_file_names);
    #Dependencies: getOversizedMM(); removeOversizedMM(); min(); max(); unique(); 
    
		my $name;my $name2; my $insertPageNumber; my $insertPageID; my %insertPageIDhash; my @insert;
		my $key; my $value; my $string; my @stringArray; my $arg;
		my $ctr=0;
        my $ctr2=15000;
		(@insert)=@_;
		#pretty("\tGIAS>>>",@insert,"\t<<<");
	foreach $name(@insert){
		
		$name2 = $name;
		$insertPageNumber=getOversizedMM($name);#TODO check these return values etc.
		$insertPageID=removeOversizedMM($name);#TODO check these return values etc.
		
		
		if($insertPageNumber ne ""){
			$insertPageIDhash{'insertPageID'.$insertPageID}=$insertPageID;#insert pageID
			
			#get the largest insert pageID page number
			if(($insertPageIDhash{'MAXmm'.$insertPageID} =~m/^(\s)*$/)||($insertPageIDhash{'MAXmm'.$insertPageID} eq undef)){#if there is no page number choose the first valid one
				$insertPageIDhash{'MAXmm'.$insertPageID}=$insertPageNumber+0;
			}else{
				$insertPageIDhash{'MAXmm'.$insertPageID}=max($insertPageNumber,$insertPageIDhash{'MAXmm'.$insertPageID});#get the maximum page number
			}
			#get the smallest insert pageID page number
			if(($insertPageIDhash{'MINmm'.$insertPageID} =~m/^(\s)*$/)||($insertPageIDhash{'MINmm'.$insertPageID} eq undef)){# if there is no page number choose the first valid one
				$insertPageIDhash{'MINmm'.$insertPageID}=$insertPageNumber+0;
			}else{
				$insertPageIDhash{'MINmm'.$insertPageID}=min($insertPageNumber,$insertPageIDhash{'MINmm'.$insertPageID});#get the minimum page number
			}
		}
	}

	#all inserts structure exists in %insertPageIDhash, now turn it into an arguments list
	foreach my $key(keys %insertPageIDhash){
		my $value = $insertPageIDhash{$key};
		#pretty("\tINSIDE>>>","\t".$value,"\t<<<");
		if($key =~ m/insertPageID/i){
			$string = '-insert='.$value;
			#pretty("\t\tINSIDE_YES>>>","\t\t".$string,"\t\t<<<YES");
			push(@stringArray,$string);
		}
	}

	foreach my $key(keys %insertPageIDhash){
		my $value = $insertPageIDhash{$key};
		$ctr++;
		if($key =~ m/^MAXmm/i){
			$key=~s/MAXmm//i;
			foreach my$element (@stringArray){
				if($element =~ m/insert=$key/){#BUGGY
					$element = $element.'/MAXmm='.($value+0);
					#eliminate duplicate entries from string
					my @splitArgArray; my @uniqueArgArray;
					(@splitArgArray)=split(/\//,$element);
					(@uniqueArgArray)=unique(@splitArgArray);
					$element = join('/',sort(@uniqueArgArray));# -insert has to be the first element
				}
			}

		}
	}

	foreach my $key(keys %insertPageIDhash){
		my $value = $insertPageIDhash{$key};
		$ctr2++;
		if($key =~ m/^MINmm/i){
			$key=~s/MINmm//i;
			foreach my$element (@stringArray){
				if($element =~ m/insert=$key/){#BUGGY
					$element = $element.'/MINmm='.($value+0);
					#eliminate duplicate entries from string
					my @splitArgArray; my @uniqueArgArray;
					(@splitArgArray)=split(/\//,$element);
					(@uniqueArgArray)=unique(@splitArgArray);
					$element = join('/',sort(@uniqueArgArray));# -insert has to be the first element
				}
			}

		}
	}

	$arg =join(' ',sort(@stringArray));
	return($arg);
}

sub getOversized{
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

    if($key3=~m/(\D)+(\d)+(_|-)fr(\d)+(_|-)(\d)+(_|-)(\d+)$/){#front matter oversize file name
        $insert = $key2;
    }
    
    elsif($key3=~m/(\D)+(\d)+(_|-)bk(\d)+(_|-)(\d)+(_|-)(\d+)$/){#back matter oversize file name
        $insert = $key2;
    }
	
	elsif($key3=~m/(\D)+(\d)+(_|-)(\d){6}(_|-)(\d)+(_|-)(\d+)$/){#paginated oversize _mm_nn file name
        $insert = $key2;
    }
    else{
        $insert = '';# not oversized
    }
	#print "\n\tOVR1>>>".$insert."<<<\n";
    return $insert;
}

sub getOversizedArgString{
	#About: Produces an argument for oversized file names
    #Input: file names that match the insert names naming convention
    #Output: A string that contains the information necessary to check insert file names (used by RS2017_exist)
    #Usage: getOversizedAargString(@array_of_oversized_file_names);
    #Dependencies: getOversizedNN(); removeOversizedNN(); getOversizedMM(); removeOversizedMM(); min(); max(); unique(); 
    
		my $name;my $name2; my $oversizedMM; my $oversizedNN; my $oversizedPageID; my %oversizedPageIDhash; my @insert;
		my $key; my $value; my $string; my @stringArray; my $arg;
		(@insert)=@_;
	foreach $name(@insert){
		
		$name2 = $name;
		$oversizedNN=getOversizedNN($name);#TODO check these return values etc.
		#print"\nOARG_NN>>>$oversizedNN<<<\n";
		$name=removeOversizedNN($name);#TODO check these return values etc.
		$oversizedMM=getOversizedMM($name);#TODO check these return values etc.
		$oversizedPageID=removeOversizedMM($name);#TODO check these return values etc.
		
		
		if($oversizedNN ne ""){
			$oversizedPageIDhash{'oversizedPageID'.$oversizedPageID}=$oversizedPageID;#oversized pageID
			
			#get the largest insert pageID page number
			if(($oversizedPageIDhash{'MAXmm'.$oversizedPageID} =~m/^(\s)*$/)||($oversizedPageIDhash{'MAXmm'.$oversizedPageID} eq undef)){#if there is no page number choose the first valid one
				$oversizedPageIDhash{'MAXmm'.$oversizedPageID}=$oversizedMM+0;
			}else{
				$oversizedPageIDhash{'MAXmm'.$oversizedPageID}=max($oversizedMM,$oversizedPageIDhash{'MAXmm'.$oversizedPageID});#get the maximum page number
			}
			#get the smallest insert pageID page number
			if(($oversizedPageIDhash{'MINmm'.$oversizedPageID} =~m/^(\s)*$/)||($oversizedPageIDhash{'MINmm'.$oversizedPageID} eq undef)){# if there is no page number choose the first valid one
				$oversizedPageIDhash{'MINmm'.$oversizedPageID}=$oversizedMM+0;
			}else{
				$oversizedPageIDhash{'MINmm'.$oversizedPageID}=min($oversizedMM,$oversizedPageIDhash{'MINmm'.$oversizedPageID});#get the minimum page number
			}
			#get the largest insert pageID page number
			if(($oversizedPageIDhash{'MAXnn'.$oversizedPageID} =~m/^(\s)*$/)||($oversizedPageIDhash{'MAXnn'.$oversizedPageID} eq undef)){#if there is no page number choose the first valid one
				$oversizedPageIDhash{'MAXnn'.$oversizedPageID}=$oversizedNN+0;
			}else{
				$oversizedPageIDhash{'MAXnn'.$oversizedPageID}=max($oversizedNN,$oversizedPageIDhash{'MAXnn'.$oversizedPageID});#get the maximum page number
			}
			#get the smallest insert pageID page number
			if(($oversizedPageIDhash{'MINnn'.$oversizedPageID} =~m/^(\s)*$/)||($oversizedPageIDhash{'MINnn'.$oversizedPageID} eq undef)){# if there is no page number choose the first valid one
				$oversizedPageIDhash{'MINnn'.$oversizedPageID}=$oversizedNN+0;
			}else{
				$oversizedPageIDhash{'MINnn'.$oversizedPageID}=min($oversizedNN,$oversizedPageIDhash{'MINnn'.$oversizedPageID});#get the minimum page number
			}
		}
	}

	#all inserts structure exists in %oversizedPageIDhash, now turn it into an arguments list
	foreach my $key(keys %oversizedPageIDhash){
		my $value = $oversizedPageIDhash{$key};
		#pretty("\tINSIDE>>>","\t".$value,"\t<<<");
		if($key =~ m/oversizedPageID/i){
			$string = '-oversized='.$value;
			#pretty("\t\tINSIDE_YES>>>","\t\t".$string,"\t\t<<<YES");
			push(@stringArray,$string);
		}
	}

	foreach my $key(keys %oversizedPageIDhash){
		my $value = $oversizedPageIDhash{$key};
		#print"\n\tOARG_E1>>><<<";
		if($key =~ m/MAXmm/i){
			$key=~s/MAXmm//i;
			#print"\n\tOARG_E2>>><<<";
			foreach my$element (@stringArray){
			#print"\n\tOARG_E3>>>$element<<<";
				if($element =~ m/(\-)*oversized=$key/){#BUGGY
					$element = $element.'/MAXmm='.($value+0);#turn the value into an number
					#print"\n\t\tOARG_E4>>>$element<<<";
					#eliminate duplicate entries from string
					my @splitArgArray; my @uniqueArgArray;
					(@splitArgArray)=split(/\//,$element);
					(@uniqueArgArray)=unique(@splitArgArray);
					$element = join('/',sort(@uniqueArgArray));# -insert has to be the first element
				}
			}

		}
	}

	foreach my $key(keys %oversizedPageIDhash){
		my $value = $oversizedPageIDhash{$key};
		
		if($key =~ m/MINmm/i){
			$key=~s/MINmm//i;
			foreach my$element (@stringArray){
				if($element =~ m/(\-)*oversized=$key/){#BUGGY
					$element = $element.'/MINmm='.($value+0);
					#eliminate duplicate entries from string
					my @splitArgArray; my @uniqueArgArray;
					(@splitArgArray)=split(/\//,$element);
					(@uniqueArgArray)=unique(@splitArgArray);
					$element = join('/',sort(@uniqueArgArray));# -insert has to be the first element
					
				}
			}

		}
	}
	
		foreach my $key(keys %oversizedPageIDhash){
		my $value = $oversizedPageIDhash{$key};
		
		if($key =~ m/MAXnn/i){
			$key=~s/MAXnn//i;
			foreach my$element (@stringArray){
				if($element =~ m/(\-)*oversized=$key/){#BUGGY
					$element = $element.'/MAXnn='.($value+0);
					#eliminate duplicate entries from string
					my @splitArgArray; my @uniqueArgArray;
					(@splitArgArray)=split(/\//,$element);
					(@uniqueArgArray)=unique(@splitArgArray);
					$element = join('/',sort(@uniqueArgArray));# -insert has to be the first element
					
				}
			}

		}
	}

	foreach my $key(keys %oversizedPageIDhash){
		my $value = $oversizedPageIDhash{$key};
		
		if($key =~ m/MINnn/i){
			$key=~s/MINnn//i;
			foreach my$element (@stringArray){
				if($element =~ m/(\-)*oversized=$key/){#BUGGY
					$element = $element.'/MINnn='.($value+0);
					#eliminate duplicate entries from string
					my @splitArgArray; my @uniqueArgArray;
					(@splitArgArray)=split(/\//,$element);
					(@uniqueArgArray)=unique(@splitArgArray);
					$element = join('/',sort(@uniqueArgArray));# -insert has to be the first element
					
				}
			}

		}
	}

	$arg =join(' ',@stringArray);
	#print"\n\t\tOARG_STRING>>>$arg<<<\n";
	return($arg);
}

sub getOversizedMM{
    #About: gets the _MM sequence from the oversized file's filename if applicable, otherwise returns a space character
    #Input: $string filename without extension, without role
    #Output:  _MM sequence
    #Usage: $output = getOversizedMM($input)
    my $key2; my $key3; my @parts;
    $key2=shift;
    $key3=$key2;
    
    if($key3=~m/(\D)+(\d)+(_|-)fr(\d)+(_|-)(\d)+$/i){#oversized frontmatter NN file name
		(@parts) = split(/(_|-)+/,$key2);
		#print "MATCH2 oversized frontmatter NN";
        return pop(@parts);
    }elsif($key3=~m/(\D)+(\d)+(_|-)bk(\d)+(_|-)(\d)+$/i){#oversized backmatter NN file name
		(@parts) = split(/(_|-)+/,$key2);
		#print "MATCH3 oversized backmatter NN";
        return pop(@parts);
    }elsif($key3=~m/(\D)+(\d)+(_|-)(\d){6}(_|-)(\d)+$/i){#oversized paginated NN file name
		(@parts) = split(/(_|-)+/,$key2);
		#print "MATCH oversized paginated NN";
        return pop(@parts);
    }else{
		#print "MATCH4 no match";
        return ' ';
    }  
}

sub getOversizedNN{
    #About: gets the _MM sequence from the oversized file's filename if applicable, otherwise returns a space character
    #Input: $string filename without extension, without role
    #Output:  _MM sequence
    #Usage: $output = getOversizedMM($input)
    my $key2; my $key3; my @parts;
    $key2=shift;
    $key3=$key2;
    #print"\nkey>>>$key3<<<";
    if($key3=~m/(\D)+(\d)+(_|-)fr(\d)+(_|-)(\d)+(_|-)(\d)+$/i){#oversized frontmatter NN file name
		(@parts) = split(/(_|-)+/,$key2);
		#print "\tMATCH1 oversized frontmatter NN";
        return pop(@parts);
    }elsif($key3=~m/(\D)+(\d)+(_|-)bk(\d)+(_|-)(\d)+(_|-)(\d)+$/i){#oversized backmatter NN file name
		(@parts) = split(/(_|-)+/,$key2);
		#print "\tMATCH2 oversized backmatter NN";
        return pop(@parts);
    }elsif($key3=~m/(\D)+(\d)+(_|-)(\d){6}(_|-)(\d)+(_|-)(\d)+$/i){#oversized paginated NN file name
		(@parts) = split(/(_|-)+/,$key2);
		#print "\tMATCH3 oversized paginated NN";
        return pop(@parts);
    }else{
		#print "\tMATCH4 no match";
        return ' ';
    }  
}

sub getPageID{
    #About: extracts the paginated page from a filename without an extension, without a role, without the oversized _xx or _xx_yy character sequence if applicable. Otherwise returns a space character.
    #Input: string_123456
    #Output: 123456
    #Usage: $output = getPageID($input)
    
    my $key2; my $PageID;
    $key2 = shift;
    if($key2=~m/(_|-)+(\d)+$/){
        
        $PageID=substr($key2,$-[0],$+[0]-$-[0]); #extract matched substring
        $PageID=~s/^(_|-)+//;
        $PageID=~s/(_|-)+$//;
        $PageID=$PageID+0;
        $key2=~s/(_|-)(\d)+$//;
        $PageID=$PageID+0;
        #print "PageID $PageID matched\n";
        return $PageID;
    }else{
        return ' ';
    }   
}

sub getPartID{
    #About: creates a PartID from the filename
    #Input: $string filename without extension and without role. examples: (not full list)
	#	Partner_Collection123456_123456_12_12 or 
	#	Partner_Collection123456_123456_12 or 
	#	Partner_Collection123456_123456
    #$Output: $string containing the PartID example: Partner_Collection123456
    #Usage: $output = getPartID($input)
    #Dependencies: removeOversizedMM(); removeOversizedNN(); removePageID();
    my $key2; my $key3; my $key10; my $key11; my $key12; my $key13; my $key14; my $PartID;
    $key2=shift;
    $key3=$key2;#make a copy of the input
	
	$key10 = removeOversizedNN($key3);# remove oversized NN
	$key3   = $key10 unless $key10 eq ' ';#check if it was successful
	
	$key11 = removeOversizedMM($key3);# remove oversized MM
	$key3   = $key11 unless $key11 eq ' ';#check if it was successful
	
	$key12 = removeFrontMatter($key3);# remove oversized MM
	$key3   = $key12 unless $key12 eq ' ';#check if it was successful
	
	$key13 = removeBackMatter($key3);# remove oversized MM
	$key3   = $key13 unless $key13 eq ' ';#check if it was successful
	
	$key14 = removePageID($key3);# remove oversized MM
	$key3 = $key14 unless $key14 eq ' ';#check if it was successful
	
	#print "\nFNPTID>>>$key12<<<";
	#print "\nFNPTID>>>$key13<<<";
	#print "\nFNPTID>>>$key14<<<";
	$PartID = $key3;
    return $PartID;
}

sub getPartnerID{
    #About: extracts the PartnerID from the PartID
    #Input: Partner_collection123456
    #Output: Partner
    #Usage: $output = getPartnerID($input)
    #Dependency: getPartID()
    
    my $PartID; my $CollectionCode;
    $PartID = shift;
    $PartID =~ m/^(\w|\W)+_/;        
    $PartnerID = substr($PartID,$-[0],$+[0]-$-[0]);#get the matched section
    $PartnerID =~ s/(_|-)+$//;
    return $PartnerID;
}

 sub getRole{
    #About: extracts the role of the file. For example d for derivative, m for master etc.
    #Input: $string filename without extension
    #$Output: $string containing _m or _d etc.
    #Usage: $output = getRole($input)   
    
    my $string;
	my @parts;
    my $role;
    $string =shift;
	$string =~ s/(_|-)+$//;
	
	(@parts)=split(/(-|_)+/,$string);
	$role = pop(@parts);
	undef(@parts);
	#print"\n\tROL>>>$role<<<";
	return $role;   
}

sub getSubfolders{
    #About: returns a list of subdirectory names
    #Input: full path to the directory whose contents are to be listed
    #Output: list of subdirectories inside the directory being checked
    #Usage: $output = getSubfolders(Input)
    #Dependency: none
    
    my @subfolders; my $directory_path;
    $directory_path = shift;
    #get all subfolder names
    opendir($DH, $directory_path) || die "can't open $directory_path; $!";
        @subfolders = grep {!/^(\.)+$/ && -d "$directory_path;/$_"} readdir($DH); # all folders except (. ..) etc
    closedir $DH;
    return @subfolders;
}

sub getUOW{
     # Collection123456
    #About: extracts the Unit of Work number from the PartID
    #Input: Partner_collection123456
    #Output: 123456
    #Usage: $output = getUOW($input)
    #Dependency: getPartID()
    
    my $PartID; my $UOW;
    $PartID = shift;
	#print "\nPARTID>>>$PartID<<<";
    $PartID =~ s/^\w+(_|-)+//i;
	$PartID =~ s/(\D)+//i;
	#print "\n\tPARTID>>>$PartID<<<";
    $UOW = $PartID;
	
    return $UOW;
}

sub getVisibleFiles{
    #About: returns a list of filenames that are not hidden files
    #Input: full path to the directory whose contents are to be listed
    #Output: list of filenames
    #Usage: $output = getVisibleFiles(Input)
    #Dependency: none
    
    my $directory_path; my @files;
    $directory_path = shift;
	#print"\nGVF directoryPath>>>$directory_path<<<\n";
    #get non-hidden filenames
    opendir(my $DH, $directory_path) || die "can't open $directory_path $!";
        @files = grep {!/^(\.)+/ && -f "$directory_path/$_"} readdir($DH); # all files that not hidden
    closedir $DH;
    return @files;
}


sub max{
    #About: returns the maximum number given two numners as input, else returns a space character
    #Input: list of numbers; example: @numbers =(1,2,3);
    #Output: number with the maximum value; example: 3
    #Usage: $output = max(Input)
    #Dependency: none
    
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
    #Dependency: none
    
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

sub pass{
#purpose: display an ASCII PASS graphic on the command line
#input: void
#output: prints the PASS graphic to STDOUT
#sample usage: pass();
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



sub removeBackMatter{
    #About: removes the back matter page number(_bk00 or -bk00) from the filename when possible
    #Input: $string filename without extension and without role.
    #Output: $string without the back matter page number
    #Usage: $output = removeBackMatter($input)
    my $string;
    $string = shift;

    $string =~ s/(_|-)+$//;
	if($string =~m/(_|-)bk(\d)+$/i){
		$string =~ s/(_|-)bk(\d)+$//i;
	}else{
		$string = ' ';
	}
    return $string;
}

sub removeExtension{
    #About: removes the characters after a "." character, including the dot: for example: abc.txt --> abc
    #Input: $string
    #$Output: $string
    #Usage: $output = removeExtension($input)
    my $string;
    $string = shift;
    $string =~ s/\.(\w)+$//;
    return $string;
} 

sub removeFrontMatter{
    #About: removes the front matter page number(_fr00 or -fr00) from the filename when possible
    #Input: $string filename without extension and without role.
    #$Output: $string without the front matter page number
    #Usage: $output = removeFrontMatter($input)
    my $string;
    $string = shift;

    $string =~ s/(_|-)+$//;
	if($string =~m/(_|-)fr(\d)+$/i){
		$string =~ s/(_|-)fr(\d)+$//i;
	}else{
		$string = ' ';
	}
    return $string;
}

sub removeOversizedNN{
    #TODO: getOversizedMMNN
    #About: removes the _MM_NN sequence from the oversized file's filename if applicable, otherwise returns a space character
    #Input: $string filename without extension, without role
    #Output: $string filename without _MM_NN sequence
    #Usage: $output = removeOversizedMMNN($input)
    my $key2; my $key3;
    $key2=shift;
    $key3=$key2;
    
    if($key3=~m/(\D)+(\d)+(_|-)fr(\d)+(_|-)(\d)+(_|-)(\d)+$/i){#oversized frontmatter MM NN file name
		$key2=~s/(_|-)(\d)+$//; #removes _NN
		#print "MATCH1 oversized frontmatter MM NN";
        return $key2;
    }elsif($key3=~m/(\D)+(\d)+(_|-)bk(\d)+(_|-)(\d)+(_|-)(\d)+$/i){#oversized backmatter MM NN file name
		$key2=~s/(_|-)(\d)+$//; #removes _NN
		#print "MATCH2 oversized backmatter MM NN";
        return $key2;
    }elsif($key3=~m/(\D)+(\d)+(_|-)(\d){6}(_|-)(\d)+(_|-)(\d)+$/i){#oversized paginated MM NN file name
		$key2=~s/(_|-)(\d)+$//; #removes _NN
		#print "MATCH3 oversized paginated MM NN";
        return $key2;
    }else{
		#print "MATCH4 no match";
        return ' ';
    }  
}

sub removeOversizedMM{
    #TODO: getOversizedMM
    #About: removes the _MM sequence from the oversized file's filename if applicable, otherwise returns a space character
    #Input: $string filename without extension, without role
    #Output: $string filename without _MM sequence
    #Usage: $output = removeOversizedMM($input)
    my $key2; my $key3;
    $key2=shift;
    $key3=$key2;
    
    if($key3=~m/(\D)+(\d)+(_|-)fr(\d)+(_|-)(\d)+$/i){#oversized frontmatter MM file name
		$key2=~s/(_|-)(\d)+$//; #removes _MM
		#print "MATCH2 oversized frontmatter MM";
        return $key2;
    }elsif($key3=~m/(\D)+(\d)+(_|-)bk(\d)+(_|-)(\d)+$/i){#oversized backmatter MM file name
		$key2=~s/(_|-)(\d)+$//; #removes _MM
		#print "MATCH3 oversized backmatter MM";
        return $key2;
    }elsif($key3=~m/(\D)+(\d)+(_|-)(\d){6}(_|-)(\d)+$/i){#oversized paginated MM file name
		$key2=~s/(_|-)(\d)+$//; #removes _MM
		#print "MATCH oversized paginated MM";
        return $key2;
    }else{
		#print "MATCH4 no match";
        return ' ';
    }   
}

sub removePageID{
    #About: removes the paginated page from a filename without an extension, without a role, without the oversized _MM or _MM_NN character sequence if applicable, without frontmatter, without backmatter. Otherwise returns a space character.
    #Input: partner_collection123456_123456
    #Output: partner_collection123456
    #Usage: $output = getPageID($input)
    
    my $key2;
	my $key3;
    $key2 = shift;
	$key3 =$key2;
	
    
	if($key3=~m/(\D)+(\d)+(_|-)(\d)+$/i){#paginated file name
		$key2=~s/(_|-)(\d)+$//; #removes _123456
		#print "MATCH paginated";
        return $key2;
    }else{
		#print "MATCH4 no match";
        return ' ';
    } 
    return $key2;
}

sub removeRole{
    #About: removes the role of the file. For example: roles are _d for derivative, _m for master etc. abc_d --> abc; 
    #Input: $string filename without extension
    #$Output: $string without _m or _d
    #Usage: $output = removeRole($input)   
    my $string;
    $string = shift;
    $string =~ s/(_|-)+$//;
    $string =~ s/(_|-)\D+$//;
    
    return $string;
}


sub showHelp{
    #About: show a message to help users use the program
    #Input: none
    #output: the text written below
    #usage: showHelp();
    print "\nTo use this program: type its path into a terminal and then";
    print "\ntype the path of the folder you want to check ";
    print "\nSample: /Path/to/script/Program_Name.pl /Path/to/some/folder\n\n";
}

sub showVersion{
    #About: Show a message when the user wants to obtain version information
    #Input: none;
    #output: the text written below;
    #usage showVersion();
    print "\nVersion 1.3 (NonBatch Hyphen)\n\n";	
}

sub unique{
    #About: return a perl array with unique entries
    #Input: @inputArray
    #$Output: @outputArray
    #Usage: (@output)= unique(@inputArray);
    my %hash;
    foreach(@_){
        $hash{$_} = undef; #set the value of each key to undef
    }
    return keys(%hash);
}

sub pretty{
    #About: print to STDOUT the contents of a List one element per line
    #Input: ('some',$elements,@List)
    #Output: prints to STDOUT the contents of the Array
    #dependency: none
	foreach(@_){
		print "\n".$_;
	}
	print "\n";
}