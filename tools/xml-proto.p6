#!/usr/bin/env perl6

use XML;
use XML::Entity;

for $*ARGFILES -> $file {

    my $xml = from-xml-file $file.Str;
     
    my $name    = $xml<id>;
    my $law     = $xml.lookfor( :TAG<userinput> )[0].contents;
    my $install = $xml.lookfor( :TAG<userinput> )[1].contents;
    
   say $xml[7]; 


}
