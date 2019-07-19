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
  
  my @law  = $xml.lookfor( :role<installation>, :OBJECT ).lookfor( :TAG<userinput>)>>.contents;
  my $config  = $xml.lookfor( :role<configuration>, :OBJECT ).lookfor( :TAG<userinput>)>>.contents;


  my $srcurl = $file.lines.first( /'download-http'/ ).match( / '"' <(.*?)> '"' /).Str;


  my %trans = 
  "{$name}"              => '[NAME]',
  "&{$name}-version;"    => '[AGE]',
  '&gnu-http;'           => '[GNUHTTP]',
  '&gnupg-http;'         => '[GNUFTP]',
  '&gstreamer-dl;'       => '[GSTREAMER]',
  '&kernel-dl;'          => '[KERNEL]',
  '&mozilla-http;'       => '[MOZILLA]',
  '&perl_authors;'       => '[CPAN]',
  '&sourceforge-dl;'     => '[SOURCEFORGE]',
  '&gentoo-ftp-repo;'    => '[GENTO]',
  '&xorg-download-http;' => '[XORGHTTP]',
  '&xorg-download-ftp;'  => '[XORGFTP]',
  '&pypi;'               => '[PYPI]',
  'tar.gz'               => '[TARGZ]',
  'tar.xz'               => '[TARXZ]',
  'tar.bz2'              => '[TARBZ2]';

  #say $srcurl.trans: %trans.keys => %trans.values;

  my $protocontent = qq:to/PROTO/;
  <proto>
    srcurl $srcurl

  <cluster>
    {@cluster}

  <law>
    {@law}

  <install>
    make DESTDIR=[XYZ] install

  <config>
    $config

  <desc>
    $name.

  PROTO


  my $protodir = $*CWD.add: "proto/$name";
  my $protofile = $protodir.add: "$name.proto";

  $protodir.mkdir;

  $protofile.spurt: $protocontent.trans: %trans.keys => %trans.values;
    
}



