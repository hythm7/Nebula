use lib 'lib';

use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Routes;
use Nebula;
use Nebula::Star;

my $nebula = Nebula.new: origin => $*CWD;
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
