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
  my $proto    = $protodir.add: "proto";
  my $pre-form = $protodir.add: "pre-form";


  die "proto not found for %star<star>" unless $proto.IO.e;

  $parser  = Nebula::Grammar::Proto;
  $actions = Nebula::Grammar::Proto::Actions.new;
  $m       = $parser.parsefile( $proto, :$actions );

  die "Can not parse $proto" unless $m;

  my %form = $m.ast;

  my $source = $protodir.add: %form<source>.path.IO.basename;

  LibCurl::Easy.new( URL => %form<source>.Str, download => $source.Str, :followlocation ).perform unless $source.e;

  my $tmpdir = tempdir;

  my $e = Archive::Libarchive.new: operation => LibarchiveExtract, file => $source.Str,
    flags => ARCHIVE_EXTRACT_TIME +| ARCHIVE_EXTRACT_PERM +| ARCHIVE_EXTRACT_ACL +| ARCHIVE_EXTRACT_FFLAGS;
  $e.extract: $tmpdir;
  $e.close;

  my $srcdir   = $tmpdir.IO.add( "{ %form<srcname> // %star<name> }-{ %form<srcage> // %star<age> }" );
  my $builddir = $srcdir.add: %form<builddir> // '';

  my $stardir  = $tmpdir.IO.add: %star<star>;

  $builddir.mkdir;
  $stardir.mkdir;

  my $configure-env = %form<configure><env> // '';
  my $configure-cmd = $srcdir.add: %form<configure><cmd> // 'configure';
  my $configure-law = %form<configure><law> // '';

  my $make-cmd  = %form<make><cmd> // 'make';
  my $make-what = %form<make><what> // '';

  my $install-cmd   = %form<install><cmd>   // 'make';
  my $install-what  = %form<install><what>  // 'install';
  my $install-where = %form<install><where> // 'DESTDIR';

  my $configure = "$configure-env $configure-cmd $configure-law";
  my $make      = "$make-cmd -j { %*ENV<NPROC> // chomp qx<nproc> } $make-what";
  my $install   = "$install-cmd $install-where=$stardir $install-what" ;

  run   $pre-form,  cwd => $srcdir   if $pre-form.x;
  shell $configure, cwd => $builddir if %form<configure>;
  shell $make,      cwd => $builddir if %form<make>;
  shell $install,   cwd => $builddir if %form<install>;

  my @file = find $stardir, :file;

  $!star.add(%star<name>).mkdir;
  my $a = Archive::Libarchive.new: operation => LibarchiveOverwrite,
    format => 'gnutar', filters => ['xz'],
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

  die "Can't parse star $star" unless $m;

  my %star = $m.ast;

  self.remove-star: star => %star<star>;
  $!star.add( "%star<name>/%star<star>.xyz" ).unlink;

}

