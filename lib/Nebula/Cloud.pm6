use File::Temp;
use Concurrent::File::Find;
use Path::Through;
use Libarchive::Simple;
use LibCurl::Easy;
use Nebula::Core;
use Nebula::Constants;
use Nebula::Grammar::Proto;
use Galaxy::Grammar::Star;

unit class Nebula::Cloud;
  also does Nebula::Core;

has Str $!name   = 'helix';
has Str $!target = 'x86_64-galaxy-linux';
has Str $!nproc  = chomp qx<nproc>;


multi method form ( :%star! ) {

  my $name = %star<name>;
  my $age  = %star<age>  // '0.0.1';
  my $core = %star<core> // 'x86_64';
  my $form = %star<form> // '0';
  my $tag  = %star<tag>  // $!name;
  my $star = "$name-$age-$core-$form-$tag";
  
 
  my $protodir  = "$!proto/$name".IO;
  my $patchdir  = "$!proto/$name/.patch".IO;
  my $protofile = $protodir.add: "proto";
  my $pre-form  = $protodir.add: "pre-form";
  my $post-form = $protodir.add: "post-form";

  die "proto not found for $star" unless $protofile.IO.e;
  
  my $halo = tempdir :!unlink;
  my $stardir  = $halo.IO.add: $star;
  $stardir.mkdir;

 

  my Pair $trans = < [GALAXY] [NPROC] [NAME] [AGE] [CORE] [FORM] [TAG] [XYZ] [PROTO] [GNUHTTP] [TARGZ] >
    => 
  ( $!target, $!nproc, $name, $age, $core, $form, $tag, $stardir, $protodir, GNUHTTP, TARGZ );
    
  my $proto = $protofile.slurp.trans: $trans;

  my $parser  = Nebula::Grammar::Proto;
  my $actions = Nebula::Grammar::Proto::Actions.new;
  my $m       = $parser.parse( $proto, :$actions );

  die "Can not parse $proto" unless $m;

  my %form = $m.ast;

  my $source = $protodir.add: %form<source>.path.IO.basename;
  my $srcdir = $halo.IO.add( %form<srcdir> // "$name-$age" );

  LibCurl::Easy.new( URL => %form<source>.Str, download => $source.Str, ssl-verifypeer => 0, :followlocation ).perform unless $source.e;


  .extract: destpath => $halo for archive-read $source;


  my ( $configure, $compile, $install );

  $configure = %form<configure>;
  $compile   = %form<compile>;
  $install   = %form<install>;

  #.say with $configure;
  #.say with $compile;
  #.say with $install;

  shell $pre-form,  cwd => $srcdir  if $pre-form.x;
  shell $configure, cwd => $srcdir  if $configure;
  shell $compile,   cwd => $srcdir  if $compile;
  shell $install,   cwd => $srcdir  if $install;
  shell $post-form, cwd => $stardir if $post-form.x;

  $!star.add(%star<name>).mkdir;
  
  with archive-write( $!star.add( "$name/$star.xyz" ),
    :format<gnutar>, :filter<xz>
    ) {

    indir $stardir, { .add: find $stardir.Str };
    .close;
  }

  my $location = "http://localhost:7777/star/%star<name>/%star<star>.xyz";
  self.add-star: |%form, :$location;



}


multi method blackhole ( :%star! ) {

  self.remove-star: star => %star<star>;
  $!star.add( "%star<name>/%star<star>.xyz" ).unlink;

}

