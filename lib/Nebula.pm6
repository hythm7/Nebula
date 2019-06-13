use Nebula::Cloud;
use Nebula::Routes;

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

    $!cloud.blackhole: :$star if $replace;
    $!cloud.form: :$star;

  }

}


method blackhole ( *@star ) {

  for @star -> $star {

    $!cloud.blackhole: :$star;

  }

}

