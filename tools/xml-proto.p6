#!/usr/bin/env perl6

use XML;
use XML::Entity;

for $*ARGFILES -> $file {

    my $xml = from-xml-file $file.Str;
     
    my $name    = $xml<id>;
    my $req =  $xml.lookfor( :TAG<para>, :role<required> );
    my $rec =  $xml.lookfor( :TAG<para>, :role<recommended> );

    my @req = $req[0].elements>>.attribs>>.values.flat if $req;
    my @rec = $rec[0].elements>>.attribs>>.values.flat if $rec;
    
    my @cluster = flat @req, @rec;
    
    my $form  = $xml.lookfor( :role<installation>, :OBJECT ).lookfor( :TAG<userinput>)>>.contents;
    my $config  = $xml.lookfor( :role<configuration>, :OBJECT ).lookfor( :TAG<userinput>)>>.contents;
    
    say $form;
    say "=============================";
    say $config;
}

