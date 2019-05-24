use lib 'lib';

use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Routes;
use Nebula;

my $raku = { :name<raku>, :age<0.0.1>, :core<x86_64>, :form<0> };
my $dovy = { :name<dovy>, :age<0.0.2>, :core<x86_64>, :form<1> };
my $nimo = { :name<nimo>, :age<0.0.3>, :core<x86_64>, :form<2> };

my @star = $raku, $dovy, $nimo;

my $nebula = Nebula.new: origin => $*CWD, :@star;
my $application = routes($nebula);

my Cro::Service $http = Cro::HTTP::Server.new(
  http => <1.1>,
  host => %*ENV<NEBULA_HOST> ||
    die("Missing NEBULA_HOST in environment"),
  port => %*ENV<NEBULA_PORT> ||
    die("Missing NEBULA_PORT in environment"),
  :$application,
  after => [
    Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
  ]
);

$http.start;
say "Listening at http://%*ENV<NEBULA_HOST>:%*ENV<NEBULA_PORT>";
react {
  whenever signal(SIGINT) {
    say "Shutting down...";
    $http.stop;
    done;
  }
}
