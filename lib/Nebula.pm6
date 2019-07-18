use Nebula::Cloud;
use Nebula::Routes;
use Galaxy::Grammar::Star;

unit class Nebula;
  also does Nebula::Core;

has Str $.name;
has Int $.port;

has Cloud  $!cloud;
has Routes $!routes handles <serve>;

submethod TWEAK ( ) {

  $!cloud  = Cloud.new;
  $!routes = Routes.new;

}

method form ( *@star, :$replace  = True) {

  for @star.race -> $star {
      
    my $parser  = Galaxy::Grammar::Star;
    my $actions = Galaxy::Grammar::Star::Actions.new;
    my $m       = $parser.parse( $star, :$actions );

    fail "Can't parse star $star" unless $m;

    my %star = $m.ast;

    $!cloud.blackhole: :%star if $replace;
    $!cloud.form: :%star;

  }

}


method blackhole ( *@star ) {

  for @star -> $star {

    $!cloud.blackhole: :$star;

  }

}

