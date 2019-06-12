use Nebula::Core;
use Cro::HTTP::Server;
use Cro::HTTP::Router;
use Cro::HTTP::Log::File;

unit class Nebula::Routes;
  also does Nebula::Core;

has Str:D $.host = 'localhost';
has Int:D $.port = 7777;

method routes ( ) {

  route {
    get -> 'stars' {
      my $json = self!all-stars;
      content 'application/json', $json;
    }
    get -> 'star', *@star {
      my $json = self!select-star( |@star );
      content 'application/json', $json;
    }
  }
}


method serve ( ) {

  my $application = self.routes;

  my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    :$!host,
    :$!port,
    :$application,
    after => [
      Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
  );

  $http.start;

  say "Listening at http://$!host:$!port";

  react {
    whenever signal(SIGINT) {
      say "Shutting down...";
      $http.stop;
      done;
    }
  }
}

