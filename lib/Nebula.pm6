use DDT;
use File::Temp;
use File::Find;
use Archive::Libarchive;
use LibCurl::Easy;
use Nebula::Grammar::Proto;
use Nebula::Grammar::Meta;
use Galaxy::Grammar::Star;

unit class Nebula;

has Str $!name;
has IO  $!origin;
has IO  $!proto;
has IO  $!halo;
has     @!star;

submethod BUILD (

  :$!name   = chomp qx<hostname>;
  :$!origin = $*CWD;
  :$!proto  = $!origin.add: 'proto';
  :$!halo   = '/var/nebula/halo'.IO;

  ) {


}

multi method form ( :$star ) {

  my $parser  = Galaxy::Grammar::Star;
  my $actions = Galaxy::Grammar::Star::Actions.new;
  my %star    = $parser.parse( $star, :$actions ).ast;
  #fail 'proto not found for' unless "$!proto/$name/$age/$core/$form/$tag.proto".IO.e;
  say %star;



}

multi method form ( IO $proto ) {

  my $parser  = Nebula::Grammar::Proto;
  my $actions = Nebula::Grammar::Proto::Actions.new;
  my %form    = $parser.parsefile( $proto, :$actions ).ast;

  my $tmpdir = tempdir;
  my $source = $tmpdir.IO.add: %form<source>.path.IO.basename;

  LibCurl::Easy.new( URL => %form<source>.Str, download => $source.Str).perform;
  say $tmpdir.IO.dir;
}

method star ( $name, $age?, $core?, $form?, $tag? ) {

  my %star;

  %star.push: ( name => $name );
  %star.push: ( age  => $age )      if $age;
  %star.push: ( core => $core )     if $core;
  %star.push: ( form => $form.Int ) if $form;
  %star.push: ( tag  => $tag )      if $tag;

  @!star.grep( * ≅ %star );
}

method stars ( ) {
  @!star;
}

multi infix:<≅> ( %left, %right --> Bool:D ) {

  return False unless %left<name> ~~ %right<name>;
  return False unless Version.new(%left<age>) ~~ Version.new(%right<age> // '');
  return False unless %left<core> ~~ %right<core>;
  return False unless %left<form> ~~ %right<form>;
  return False unless %left<tag>  ~~ %right<tag>;

  True;
}
