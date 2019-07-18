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
  my $form = %star<form> // 0;
  my $tag  = %star<tag>  // $!name;
  my $star = "$name-$age-$core-$form-$tag";
  
  my $protodir  = "$!proto/$name".IO;
  my $patchdir  = "$!proto/$name/.patch".IO;
  #my $protofile = $protodir.add: "$name-$age-$core-$form-$tag.proto"    // "$name.proto";
  my $protofile = $protodir.add: "$name.proto";
  my $preform   = $protodir.add: "$name.preform";
  my $postform  = $protodir.add: "$name.postform";

  die "proto not found for $star" unless $protofile.IO.e;
  
  my $halo = tempdir;
  my $stardir  = $halo.IO.add: $star;
  $stardir.mkdir;

  my %trans =

    '[GALAXY]'  => $!target,
    '[NPROC]'   => $!nproc,
    '[NAME]'    => $name, 
    '[AGE]'     => $age,
    '[CORE]'    => $core,
    '[FORM]'    => $form,
    '[TAG]'     => $tag,
    '[XYZ]'     => $stardir,
    '[PROTO]'   => $protodir,
    '[GNUHTTP]' => GNUHTTP,
    '[TARGZ]'   => TARGZ;
    
  my $proto = $protofile.slurp.trans: %trans.keys => %trans.values;

  my $parser  = Nebula::Grammar::Proto;
  my $actions = Nebula::Grammar::Proto::Actions.new;
  my $m       = $parser.parse( $proto, :$actions );

  die "Can not parse $proto" unless $m;

  say $m.ast;

  my %form = $m.ast;

  my $source = $protodir.add: %form<source>.path.IO.basename;
  my $srcdir = $halo.IO.add( %form<srcdir> // "$name-$age" );

  say $source;

  LibCurl::Easy.new( URL => %form<source>.Str, download => $source.Str, ssl-verifypeer => 0, :followlocation ).perform unless $source.e;


  .extract: destpath => $halo for archive-read $source;

  say 'extracted';

  my $law       = %form<law>;
  my $install   = %form<install>;

  #.say with $configure;
  #.say with $compile;
  #.say with $install;

  shell $preform,   cwd => $srcdir  if $preform.x;
  shell $law,       cwd => $srcdir  if $law;
  shell $install,   cwd => $srcdir  if $install;
  shell $postform,  cwd => $stardir if $postform.x;

  $!star.add($name).mkdir;
  
  with archive-write( $!star.add( "$name/$star.xyz" ),
    :format<gnutar>, :filter<xz>
    ) {

    indir $stardir, { .add: find $stardir.Str };
    .close;
  }

  my $location = "http://localhost:7777/star/$name/$star.xyz";
  my $chksum;
  self.add-star: |%form, :$star, :$name, :$age, :$core, :$form, :$tag, :$location, :$chksum;
}


multi method blackhole ( :%star! ) {

  my $name = %star<name>;
  my $age  = %star<age>  // '0.0.1';

  self.remove-star: :$name, :$age;

}

