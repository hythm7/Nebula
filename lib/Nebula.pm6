use Nebula::Grammar::Meta;

unit class Nebula;

has Str  $.name;
has IO   $.origin;
has      @.star;

method all-stars ( ) {
  all-star => @!star;
}

method find-star ( Str $name, Str $age?, Str $core?, Str $form?, Str $tag? ) {

  @.star.grep( -> %star { %star<name> ~~ $name } );
}
