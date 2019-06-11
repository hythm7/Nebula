use Cro::HTTP::Router;
unit role Nebula::Routes;

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
