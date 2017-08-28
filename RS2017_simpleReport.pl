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



#fix the arguments as they come from the command line
$ARGUMENT_STRING=join(' ',@ARGV);
#print "\nSTRING:$ARGUMENT_STRING\n";
@ARGV=();
(@ARGV)=split(/ -/,$ARGUMENT_STRING);
foreach my $arg(@ARGV){
    $arg=' -'.$arg;
}

$argc=scalar(@ARGV);

if($argc >1){
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
    
    
    
    foreach $argument (@ARGV){
        #        print "\n>>>$argument<<<arg\n";
        if($argument =~ m/-+(help|h)/){
            showManualHelp();
            exit;
        }
        if($argument =~ m/-+(version|v)/){
            showVersion();
            exit;
        }
        elsif($argument =~ m/^ *\-+dir/ig){# partner id
            (undef,$dir) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^ *\-+partner/ig){# partner id
            (undef,$partner) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^ *\-+(collection_code|cc)/ig){
            (undef,$cc) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^ *\-+(Unit_Of_Work|uow)/ig){
            (undef,$uow) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^ *\-+(minUOW)/ig){
            (undef,$minUOW) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^ *\-+(maxUOW)/ig){
            (undef,$maxUOW) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^ *\-+(paginated_Start|pstart)/ig){
            (undef,$pstart) = split(/\=+/,$argument);
			if($pstart=~m/NOT_APPLICABLE/){
				$pstart='';
			}
        }
        elsif($argument =~ m/^ *\-+(paginated_End|pend)/ig){
            (undef,$pend) = split(/\=+/,$argument);
			if($pend=~m/NOT_APPLICABLE/){
				$pend='';
			}
        }
        elsif($argument =~ m/^ *\-+(frontmatter_Start|frstart)/ig){
            (undef,$frstart) = split(/\=+/,$argument);
			if($frstart=~m/NOT_APPLICABLE/){
				$frstart='';
			}
        }
        elsif($argument =~ m/^ *\-+(frontmatter_End|frend)/ig){
            (undef,$frend) = split(/\=+/,$argument);
			if($frend=~m/NOT_APPLICABLE/){
				$frend='';
			}
        }
        elsif($argument =~ m/^ *\-+(backmatter_Start|bkstart)/ig){
            (undef,$bkstart) = split(/\=+/,$argument);
			if($bkstart=~m/NOT_APPLICABLE/){
				$bkstart='';
			}
        }
        elsif($argument =~ m/^ *\-+(backmatter_End|bkend)/ig){
            (undef,$bkend) = split(/\=+/,$argument);
			if($bkend=~m/NOT_APPLICABLE/){
				$bkend='';
			}
        }
        elsif($argument =~ m/^ *\-+partsep/ig){ #separator between partnerID and collectioncode
            (undef,$partsep) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^ *\-+roles/i){#m d s t de dr se sr separated by forwardslash
            (undef,$roleStr) = split(/\=+/,$argument);
            (@roles)=split(/\//,$roleStr);#list of roles
            undef($roleStr);
			$roleStr=join(' , ',@roles);
            $rolec=scalar(@roles);#role count
        }
        elsif($argument =~ m/^ *\-+(extension|ext)/ig){
            (undef,$ext) = split(/\=+/,$argument);
        }
        elsif($argument =~ m/^ *\-+target/ig){
            (undef,$target) = split(/\=+/,$argument);
            if($target =~m/skip_target/i){
                $target='';
            }
        }
        
        elsif($argument =~ m/^ *\-+eoc/ig){
            (undef,$eoc) = split(/\=+/,$argument);
            if($eoc =~m/skip_eoc/i){
                $eoc='';
            }
        }
        elsif($argument =~ m/^ *\-+(directory|dir)/ig){
            (undef,$dir) = split(/\=+/,$argument);
            #print"DIRE\n\n$dir\n\n";
            #print"DIRE\n\n$dir\n\n";
        }
        elsif($argument =~ m/^ *\-+(postcard)/ig){
            (undef,$postcard) = split(/\=+/,$argument);
            
        }
    }
}
else{
    #showManualHelp();
    print "\nPlease check the arguments list.\n";
    exit;
}
#print "\n>>>$ext<<<ext\n";
#print"-dir=$dir -partner=$partner -cc=$cc -uow=$uow -pstart=$pstart -pend=$pend -frstart=$frstart -frend=$frend -bkstart=$bkstart -bkend=$bkend -roles=$roles -ext=$ext -eoc=$EOC -target=$target";

if($postcard =~m/true/i){
    #present the user with a simple report ('SUMMARY_OF_FEATURES') about the information extracted from the filenames
    $~ = 'POSTCARD_SUMMARY_OF_FEATURES';
    write; #write the 'SUMMARY_OF_FEATURES' report to STDOUT
}
else{
    #present the user with a simple report ('SUMMARY_OF_FEATURES') about the information extracted from the filenames
    $~ = 'SUMMARY_OF_FEATURES';
    write; #write the 'SUMMARY_OF_FEATURES' report to STDOUT
}

#this format uses global variables. Produces the "Summary of Features" report shown to the user which indicates what the script was able to do automatically
format SUMMARY_OF_FEATURES =
@<<<<<<<<<<<<<<<<<<<<
'SUMMARY OF FEATURES'
@||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
' ---------------------------------------------------------------------------------------------------------------- '
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<path to directory> : ', $dir,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<partner id>  (there may not be one) : ', $partner,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<collection code> : ', $cc,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<unit of work> : ', $uow,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<page id> starts : ', $pstart,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<page id> ends : ', $pend,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','front matter start : ', $frstart,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','front matter end : ', $frend,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','back matter start : ', $bkstart,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','back matter end : ', $bkend,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','Roles to be checked : ',$roleStr,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','extension : ', $ext,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','Target Name : ', $target,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','EOC Name : ', $eoc,' |'
@||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
' ---------------------------------------------------------------------------------------------------------------- '
.

#this format uses global variables. Produces the "Summary of Features" report shown to the user which indicates what the script was able to do automatically
format POSTCARD_SUMMARY_OF_FEATURES =
@<<<<<<<<<<<<<<<<<<<<
'SUMMARY OF FEATURES'
@||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
' ---------------------------------------------------------------------------------------------------------------- '
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<path to directory>: ', $dir,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<partner id>  (there may not be one) : ', $partner,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<collection code> : ', $cc,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<unit of work> starts : ', $minUOW,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<unit of work> ends : ', $maxUOW,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<page id> starts : ', $pstart,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','<page id> ends : ', $pend,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','front matter start : ', $frstart,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','front matter end : ', $frend,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','back matter start : ', $bkstart,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','back matter end : ', $bkend,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','Roles to be checked: ',$roleStr,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','extension : ', $ext,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','Target Name : ', $target,' |'
@<<@>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@>>
'| ','EOC Name : ', $eoc,' |'
@||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
' ---------------------------------------------------------------------------------------------------------------- '
.