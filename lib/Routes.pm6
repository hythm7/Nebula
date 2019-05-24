use Cro::HTTP::Router;
use Nebula;

sub routes(Nebula $nebula) is export {
  route {
    get -> 'stars' {
      my $json = to-json $nebula.all-stars;
      content 'application/json', $json;
    }
    get -> 'star', *@star {
    #get -> 'star', $name, $age?, $core?, $form?, $tag? {
      my $json = to-json $nebula.find-star( |@star );
      content 'application/json', $json;
    }
  }
}
