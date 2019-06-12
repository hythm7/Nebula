use File::Temp;
use Path::Finder;
use Path::Through;
use Archive::Libarchive;
use Archive::Libarchive::Constants;
use LibCurl::Easy;
use Nebula::Core;
use Nebula::Grammar::Proto;
use Galaxy::Grammar::Star;

unit class Nebula::Cloud;
  also does Nebula::Core;


multi method form ( Str:D :$star! ) {

  my $parser  = Galaxy::Grammar::Star;
  my $actions = Galaxy::Grammar::Star::Actions.new;
  my $m       = $parser.parse( $star, :$actions );

  fail "Can't parse star $star" unless $m;

  my %star = $m.ast;


  my $protodir = "$!proto/%star<name>/%star<star>/".IO;
  my $proto    = $protodir.add: "star.proto";

  fail "proto not found for %star<star>" unless $proto.IO.e;

  $parser  = Nebula::Grammar::Proto;
  $actions = Nebula::Grammar::Proto::Actions.new;
  $m       = $parser.parsefile( $proto, :$actions );

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

  $!star.add(%star<name>).mkdir;
  my $a = Archive::Libarchive.new: operation => LibarchiveOverwrite,
    format => 'v7tar', filters => ['xz'],
    file   => $!star.add( "%star<name>/%star<star>.xyz" ).Str;

  for @file -> $file {
      $a.write-header( ~$file, perm => $file.mode, pathname => ~$file.&shift: :4parts );
      $a.write-data( ~$file );
  }

  $a.close;

  my $location = "http://localhost:7777/star/%star<name>/%star<star>.xyz";
  self.add-star: |%form, :$location;
}


multi method blackhole ( Str:D :$star! ) {

  my $parser  = Galaxy::Grammar::Star;
  my $actions = Galaxy::Grammar::Star::Actions.new;
  my $m       = $parser.parse( $star, :$actions );

  fail "Can't parse star $star" unless $m;

  my %star = $m.ast;

  self.remove-star: star => %star<star>;
  $!star.add( "%star<name>/%star<star>.xyz" ).unlink;

}

