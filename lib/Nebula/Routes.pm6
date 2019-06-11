use Cro::HTTP::Router;
unit role Nebula::Routes;

method routes ( ) {

  route {
    get -> 'stars' {
      my $json = to-json self.stars;
      content 'application/json', $json;
    }
    get -> 'star', *@star {
      my $json = self.star( |@star );
      content 'application/json', to-json $json;
    }
  }
}
