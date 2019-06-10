use DDT;
use File::Temp;
use Path::Finder;
use Path::Through;
use Archive::Libarchive;
use Archive::Libarchive::Constants;
use LibCurl::Easy;
use Nebula::Grammar::Proto;
use Galaxy::Grammar::Star;

unit class Nebula;

has Str $!name;
has IO  $!origin;
has IO  $!proto;
has IO  $!halo;
has     $!star;

submethod BUILD (

  :$!name   = chomp qx<hostname>;
  :$!origin = $*CWD;
  :$!proto  = $!origin.add: 'proto';
  :$!star   = $!origin.add: 'star';
  :$!halo   = '/var/nebula/halo'.IO;

  ) {


}

multi method form ( :%star! ) {

  my $protodir = "$!proto/%star<name>/%star<star>/".IO;

  my $proto = $protodir.add: "star.proto";

  fail "proto not found for %star<star>" unless $proto.IO.e;

  my $parser  = Nebula::Grammar::Proto;
  my $actions = Nebula::Grammar::Proto::Actions.new;
  my $m       = $parser.parsefile( $proto, :$actions );

  fail "Can not parse $proto" unless $m;

  my %form = $m.ast;

  my $source = $protodir.add: %form<source>.path.IO.basename;

  LibCurl::Easy.new( URL => %form<source>.Str, download => $source.Str, :followlocation ).perform unless $source.e;

  my $tmpdir = tempdir;

  my $e = Archive::Libarchive.new: operation => LibarchiveExtract, file => $source.Str,
    flags => ARCHIVE_EXTRACT_TIME +| ARCHIVE_EXTRACT_PERM +| ARCHIVE_EXTRACT_ACL +| ARCHIVE_EXTRACT_FFLAGS;
  $e.extract: $tmpdir;
  $e.close;

  my $formdir = $tmpdir.IO.add( "%star<name>-%star<age>" );

  shell "%form<env> ./configure %form<law>", cwd => $formdir;
  shell "make", cwd => $formdir;
  shell "make DESTDIR=$tmpdir/%star<star> install", cwd => $formdir;

  my @file = find "$tmpdir/%star<star>", :file;

  my $a = Archive::Libarchive.new: operation => LibarchiveOverwrite,
    format => 'v7tar', filters => ['xz'],
    file   => $!star.add( "%star<name>/%star<star>.xyz" ).Str;

  for @file -> $file {
      $a.write-header( ~$file, perm => $file.mode, pathname => ~$file.&shift: :4parts );
      $a.write-data( ~$file );
  }

  $a.close;

}

method star ( $name, $age?, $core?, $form?, $tag? ) {

  my %star;

  %star.push: ( name => $name );
  %star.push: ( age  => $age )      if $age;
  %star.push: ( core => $core )     if $core;
  %star.push: ( form => $form.Int ) if $form;
  %star.push: ( tag  => $tag )      if $tag;

  #@!star.grep( * ≅ %star );
}

method stars ( ) {
  #@!star;
}

multi infix:<≅> ( %left, %right --> Bool:D ) {

  return False unless %left<name> ~~ %right<name>;
  return False unless Version.new(%left<age>) ~~ Version.new(%right<age> // '');
  return False unless %left<core> ~~ %right<core>;
  return False unless %left<form> ~~ %right<form>;
  return False unless %left<tag>  ~~ %right<tag>;

  True;
}
