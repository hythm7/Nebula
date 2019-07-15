use File::Temp;
use Concurrent::File::Find;
use Path::Through;
use Libarchive::Simple;
use LibCurl::Easy;
use Nebula::Core;
use Nebula::Grammar::Proto;
use Galaxy::Grammar::Star;

unit class Nebula::Cloud;
  also does Nebula::Core;

has $!target = 'x86_64-galaxy-linux';
has $!nproc  = chomp qx<nproc>;


multi method form ( Str:D :$star! ) {

  my $parser  = Galaxy::Grammar::Star;
  my $actions = Galaxy::Grammar::Star::Actions.new;
  my $m       = $parser.parse( $star, :$actions );

  fail "Can't parse star $star" unless $m;

  my %star = $m.ast;

  my $protodir  = "$!proto/%star<name>/%star<star>/".IO;
  my $proto     = $protodir.add: "proto";
  my $pre-form  = $protodir.add: "pre-form";
  my $post-form = $protodir.add: "post-form";


  die "proto not found for %star<star>" unless $proto.IO.e;

  $parser  = Nebula::Grammar::Proto;
  $actions = Nebula::Grammar::Proto::Actions.new;
  $m       = $parser.parsefile( $proto, :$actions );

  die "Can not parse $proto" unless $m;

  my %form = $m.ast;

  my $source = $protodir.add: %form<source>.path.IO.basename;

  LibCurl::Easy.new( URL => %form<source>.Str, download => $source.Str, ssl-verifypeer => 0, :followlocation ).perform unless $source.e;

  my $tmpdir = tempdir :!unlink;

  .extract: destpath => $tmpdir for archive-read $source;

  my $srcdir   = $tmpdir.IO.add( %form<srcdir> // "{%star<name>}-{%star<age> }" );

  my $stardir  = $tmpdir.IO.add: %star<star>;

  $stardir.mkdir;

  my ( $configure, $compile, $install );

  $configure = %form<configure>.map: *.&translate if %form<configure>;
  $compile   = %form<compile>.map:   *.&translate if %form<compile>;
  $install   = %form<install>.map:   *.&translate if %form<install>;

  #.say with $configure;
  #.say with $compile;
  #.say with $install;

  shell $pre-form,  cwd => $srcdir  if $pre-form.x;
  shell $configure, cwd => $srcdir  if $configure;
  shell $compile,   cwd => $srcdir  if $compile;
  shell $install,   cwd => $srcdir  if $install;
  shell $post-form, cwd => $stardir if $post-form.x;

  $!star.add(%star<name>).mkdir;
  
  with archive-write( $!star.add( "%star<name>/%star<star>.xyz" ),
    :format<gnutar>, :filter<xz>
    ) {

    indir $stardir, { .add: find $stardir.Str };
    .close;
  }

  my $location = "http://localhost:7777/star/%star<name>/%star<star>.xyz";
  self.add-star: |%form, :$location;

  sub translate ( Str $s --> Str ) {

  $s.trans: < [GALAXY]   [NPROC]    [XYZ] [PROTO] >
    =>      ( $!target, $!nproc, $stardir, $protodir )
}

}


multi method blackhole ( Str:D :$star! ) {

  my $parser  = Galaxy::Grammar::Star;
  my $actions = Galaxy::Grammar::Star::Actions.new;
  my $m       = $parser.parse( $star, :$actions );

  die "Can't parse star $star" unless $m;

  my %star = $m.ast;

  self.remove-star: star => %star<star>;
  $!star.add( "%star<name>/%star<star>.xyz" ).unlink;

}

