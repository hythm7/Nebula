#!/usr/bin/env perl6

use XML;
use XML::Entity;

for $*ARGFILES -> $file {

    my $xml = from-xml-file $file.Str;
     
    say decode-xml-entities $xml.Str;
    

    my $configure = $xml.lookfor( :TAG<userinput> )[0].contents[0].string;
    
    say $configure;

}
