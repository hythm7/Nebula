use DDT;
use DB::SQLite;
use File::Temp;
use Path::Finder;
use Path::Through;
use Archive::Libarchive;
use Archive::Libarchive::Constants;
use LibCurl::Easy;
use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Nebula::Routes;
use Nebula::DB;
use Nebula::Grammar::Proto;
use Galaxy::Grammar::Star;

unit class Nebula;
  also does Nebula::Routes;
  also does Nebula::DB;

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
  :$!halo   = '/var/nebula/'.IO;

  ) {

    #@!star = $!db.query( 'select * from star' ).hashes;
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

  $!star.add(%star<name>).mkdir;
  my $a = Archive::Libarchive.new: operation => LibarchiveOverwrite,
    format => 'v7tar', filters => ['xz'],
    file   => $!star.add( "%star<name>/%star<star>.xyz" ).Str;

  for @file -> $file {
      $a.write-header( ~$file, perm => $file.mode, pathname => ~$file.&shift: :4parts );
      $a.write-data( ~$file );
  }

  $a.close;

  self.add-star: |%form;
}


method serve ( :$host = 'localhost', :$port = 7777 ) {

  my $application = self.routes;

  my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    :$host,
    :$port,
    :$application,
    after => [
      Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
  );

  $http.start;

  say "Listening at http://$host:$port";

  react {
    whenever signal(SIGINT) {
      say "Shutting down...";
      $http.stop;
      done;
    }
  }
}

