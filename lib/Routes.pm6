use Cro::HTTP::Router;
use Nebula;

sub routes(Nebula $nebula) is export {
  route {
    get -> 'stars' {
      my $json = to-json $nebula.stars;
      content 'application/json', $json;
    }
    get -> 'star', *@star {
      my $json = $nebula.star( |@star );
      content 'application/json', to-json $json;
    }
  }
}
