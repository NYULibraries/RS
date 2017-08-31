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

use Cwd 'abs_path';

$current_dir=getDir();

$autoextract=$current_dir.'/RS2017_autoExtract.pl';#auto extract script location
$simpleReport =$current_dir.'/RS2017_simpleReport.pl';# the location of the 'summary of features' report
$checker=$current_dir.'/RS2017_exist.pl';#checker script
$config=$current_dir.'/RS2017.config';#configuration file
$postcard = '-postcard=false';

$pstart ='';
$frstart='';
$bkstart='';

@types=();

#(@ARGV2)=reparseTerminalInput(@ARGV);
(@ARGV2)=@ARGV;
$argc = scalar(@ARGV2);
#print "\nLINE>".$config."<";

#if you want to see the arguments that this script sees uncomment these lines
=pod
    $counter=0;
    foreach(@ARGV2){
        print "\nargv[ $counter ]>>>".$_."<<<";
        $counter++;
    }
=cut

	# print "\nARGV>>>".pretty(@ARGV)."<<<arg\n";
foreach my $argument(@ARGV2){	     
	if($argument =~ m/-+(help)/){
		showHelp();
		exit;
	}
	elsif($argument =~ m/-+(version)/){
		showVersion();
		exit;
	}
}

if($argc >=1){
	$counter=0;
	$batch  = '-batch=no';#default not batch
	$hyphen = '-hyphen=no';#default not hyphen
	$skip_target='false';#default check for target
	$skip_eoc='false';#default check for eoc
	$bagged = 'false';#default not bagged
	#check values from config file
	
	
	open(FH,"<",$config) or die $!;
	@CONFIG=<FH>;
	close(FH);
	foreach my$conf (@CONFIG){
		if($conf =~ m/^(\s)*(\/){2}/){
			#print"\nthis is a comment>>>$conf<<<\n";
		}else{#since each row contains only one instruction, use if elsif
			if($conf =~ m/(\s)*batch(\s)*=*(\s)*true/i){
				$batch  = '-batch=yes';#default not batch
			}
			elsif($conf =~ m/(\s)*hyphen(\s)*=*(\s)*true/i){
				$hyphen = '-hyphen=yes';#default not hyphen
			}
			elsif($conf =~ m/(\s)*bagged(\s)*=*(\s)*true/i){
				$bagged = 'true';#default not bagged
			}
			elsif($conf =~ m/(\s)*delete_role/i){
				$conf=~s/^(\s)*delete_role(\s)*=(\s*)//i;
				$conf=~s/\s//;
				push(@delete_role,$conf);
			}
			elsif($conf =~ m/^(\s)*add_role/i){
				$conf=~s/^(\s)*add_role(\s)*=(\s*)//i;
				$conf=~s/\s//;
				push(@add_role,$conf);
			}
			elsif($conf =~ m/(\s)*target_exists(\s)*=*(\s)*false/i){
				$skip_target = 'true';
			}
			elsif($conf =~ m/(\s)*eoc_exists(\s)*=*(\s)*false/i){
				$skip_eoc = 'true';
			}
			elsif($conf =~ m/(\s)*role_postcard(\s)*=*(\s)*true/i){
				$postcard = '-postcard=true';
			}
			#start of counters
			elsif($conf =~ m/(\s)*pstart(\s)*=*(\s)*/i){
				$conf=~s/^(\s)*pstart(\s)*=*(\s)*//i;
				$pstart=$conf+0;
			}
			elsif($conf =~ m/(\s)*frstart(\s)*=*(\s)*/i){
				$conf=~s/^(\s)*frstart(\s)*=*(\s)*//i;
				$frstart=$conf+0;
			}
			elsif($conf =~ m/(\s)*bkstart(\s)*=*(\s)*/i){
				$conf=~s/^(\s)*bkstart(\s)*=*(\s)*//i;
				$bkstart=$conf+0;
			}
			#end of counters
			elsif($conf =~ m/(\s)*pend(\s)*=*(\s)*/i){
				$conf=~s/^(\s)*pend(\s)*=*(\s)*//i;
				$pend=$conf+0;
			}
			elsif($conf =~ m/(\s)*frend(\s)*=*(\s)*/i){
				$conf=~s/^(\s)*frend(\s)*=*(\s)*//i;
				$frend=$conf+0;
			}
			elsif($conf =~ m/(\s)*bkend(\s)*=*(\s)*/i){
				$conf=~s/^(\s)*bkend(\s)*=*(\s)*//i;
				$bkend=$conf+0;
			}
			elsif($conf =~ m/(\s)*partner(\s)*=*(\s)*/i){
				$conf=~s/^(\s)*partner(\s)*=*(\s)*//i;
				$partner=$conf;
			}
			elsif($conf =~ m/(\s)*cc(\s)*=*(\s)*/i){
				$conf=~s/^(\s)*cc(\s)*=*(\s)*//i;
				$cc=$conf;
			}
			elsif($conf =~ m/(\s)*uowstart(\s)*=*(\s)*/i){
				$conf=~s/^(\s)*uowstart(\s)*=*(\s)*//i;
				$minuow=$conf;
			}
			elsif($conf =~ m/(\s)*uowend(\s)*=*(\s)*/i){
				$conf=~s/^(\s)*uowend(\s)*=*(\s)*//i;
				$maxuow=$conf;
			}
			
		}
	}
	#print "\n\tpstart= $pstart>\n\t frstart= $frstart>\n\t bkstart= $bkstart>";
	#now go through each argument as if it were a folder path
	foreach my $argument (@ARGV2){
		#$argument=quotemeta($argument);# bug exists in auto extract. when directory has a space character
		
		if($bagged eq 'true'){
			if($argument=~m/\'$/){
				$argument=~s/\'$//;
				$argument=~s/^\'//;
				$argument=~s/$(\\|\/)+//;
				$argument=$argument."/data";
			}elsif($argument=~m/\"$/){
				$argument=~s/\"$//;
				$argument=~s/^\"//;
				$argument=~s/$(\\|\/)+//;
				$argument=$argument.'/data';
			}else{
				$argument=$argument.'/data';
			}
		}
		
		if($argument !~ m/^\s*(\'|\")/){
			$argument='"'.$argument;
		}
		if($argument !~ m/(\'|\")\s*$/){
			$argument=$argument.'"';
		}
		$checkDir=$argument;
		
		#print "\nRunning!$argument\n";
		#print"\nperl \"$autoextract\" -dir=$checkDir\n";
		$args =`perl "$autoextract" -dir=$checkDir`; #extract basic data
		#print "\nARGS>>>$args<<<\n";
		$args =deleteAllRoles($args);
		#$args =deleteRole($args,@delete_role);
		#print"\nNOROLE$args\n";
		$args =addRole($args,@add_role);
		#print"\nWITHROLE$args\n";
		if($skip_target eq 'true'){
			$args = join(' ',replaceKeyValue('-target=','skip_target',split(/ /,$args)));
		}
		if($skip_eoc eq 'true'){
			$args = join(' ',replaceKeyValue('-eoc=','skip_eoc',split(/ /,$args)));
		}
		# start counters
		if($pstart ne ''){
			$args = join(' ',replaceKeyValue('-pstart=',$pstart,split(/ /,$args)));
		}
		if($frstart ne ''){
			$args = join(' ',replaceKeyValue('-frstart=',$frstart,split(/ /,$args)));
		}
		if($bkstart ne ''){
			$args = join(' ',replaceKeyValue('-bkstart=',$bkstart,split(/ /,$args)));
		}
		#end counters
		if($pend ne ''){
			$args = join(' ',replaceKeyValue('-pend=',$pend,split(/ /,$args)));
		}
		if($frend ne ''){
			$args = join(' ',replaceKeyValue('-frend=',$frend,split(/ /,$args)));
		}
		if($bkend ne ''){
			$args = join(' ',replaceKeyValue('-bkend=',$bkend,split(/ /,$args)));
		}
		
		if($partner ne ''){
			$args = join(' ',replaceKeyValue('-partner=',$partner,split(/ /,$args)));
		}
		if($cc ne ''){
			$args = join(' ',replaceKeyValue('-cc=',$cc,split(/ /,$args)));
		}
		if($minuow ne ''){
			$args = join(' ',replaceKeyValue('-minUOW=',$minuow,split(/ /,$args)));
		}
		if($maxuow ne ''){
			$args = join(' ',replaceKeyValue('-maxUOW=',$maxuow,split(/ /,$args)));
		}
		
		#$number=10;
		#print sprintf("%0".$number."d","11");
		
		#print "\nARGS2>>>$args<<<\n";
		$argstring= 'perl "'.$simpleReport.'" '."$args $postcard"; # produce a summary of features report
		$argstring=~s/(\n|\r)//ig;
		#print "\nARGSTRING>>>$argstring<<<\n";
		print `$argstring`;
		#print"SYSARG>>>perl $checker $args $hyphen $batch <<<";
		#system("perl $checker $args $hyphen $batch "); # check arguments
		$checker_argstring='perl "'.$checker.'" '."$args $hyphen $batch $postcard";
		$checker_argstring=~s/(\n|\r)//ig;
		#print "\n\nchecker>>>$checker_argstring<<<\n\n";
		print `$checker_argstring`; # check arguments
		print"\n\n";
		$counter++;
	}
	print "\nprocessed: $counter folders\n";
}else{
	print "\nYou must enter at least one folder path!\n";
}
		


sub addRole{
    #About      : add role to be checked from the argument list
    #Input      : ('string of arguments',array_containing_the_roles)
    #Output     : a string formatted as follows: -roles=role1/role2/role3 where each role gets appended to this string
    #Usage      : addRole('string_of_arguments',@array_of_roles_one_role_per_index)
    #Dependency : none
	my @ARGSTR; my $args; my $arg_str2; my $role2add; my @ARGSTR2; my @add_role;
	$args=shift;
    $args=~s/\s+$//;
	@add_role=@_;
    $role2add=join('/',@add_role);
    $role2add=~s/\s+//g;
    $role2add='-roles='.$role2add;
    $args=$args.' '.$role2add;
	return($args);
}

  sub deleteAllRoles{
    #About: go through a string seeking '-roles'. if found, remove it from the list. 
    #Input: ('string containing arguments')
    #Output: A string without -roles=role1/role2/role3
    #usage: $output_string=deleteAllRoles('space_separated_string_of_roles');
    #depencency: none
	my @ARGSTR; my $args; my $arg_str2; my @ARGSTR2;
	$args=shift;
	#@delete_role=@_;
	(@ARGSTR)=split(/ /,$args);
	foreach my $arg_str2(@ARGSTR){
		if($arg_str2 !~ m/-*roles/){
			push(@ARGSTR2,$arg_str2);
		}
	}
	
	$args=join(' ',@ARGSTR2);
	return($args);
}
 
 
sub getDir{
    #About: Find the directory where this script is located in
    #Input: none
    #Output: path to the directory (with forward-slash as the path separator) , deletes the last forward slash example: /path/to/dir
    #Usage: $directory = getDir();
    #
	#Dependency: use Cwd 'abs_path';# this is a standard perl module
    #
	my $current_path;
	my @path_component;
	my $garbage;
	my $dir;
	#get the absolute path of the directory where the program exists;
	$current_path=abs_path($0);
	(@path_component)=split(/\//,$current_path);
	$garbage=pop(@path_component);#$garbage contains this program's name
	undef($garbage);
	$dir=join('/',@path_component);
    $dir=~s/\/$//;
	return $dir;
}

sub replaceKeyValue{
    #About: replaces the value of a key-value pair (not hash)
    #Input: ('-someFlag=','someNewReplacementValue', @Array_of_key_value_pairs)
    #Output: the Array of key-value pairs where every instance of '-someFlag=' had its value 'someValue' replaced with 'someNewReplacementValue'
    #Usage: @OutputArray =replaceKeyValue('-someFlag=','someNewReplacementValue', @Array_of_key_value_pairs)
    #Dependency: none
    
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

sub showHelp{
    #About: show a message to help users use the program
    #Input: none
    #output: the text written below
    #usage: showHelp();
	print "\nRS2017.pl path/to/folder/to/be/checked path/to/folder/to/be/checked path/to/folder/to/be/checked";
	print "\nRS2017 (C) 2017 Wilfredo Rosario. All Rights Reserved.\n";
}
sub showVersion{
    #About: Show a message when the user wants to obtain version information
    #Input: none;
    #output: the text written below;
    #usage showVersion();
	print "\nRS2017 Version 2.1";
	print "\nCopyright (C) 2017 Wilfredo Rosario. All Rights Reserved.\n";
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