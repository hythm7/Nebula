use File::Find;
use Nebula::Grammar::Meta;

unit class Nebula;

has Str $.name;
has IO  $.origin;
has     @!star;

method TWEAK ( ) {

  # Temporary
  my @file = find( dir => 'meta', name => / '.meta' $ / );

  for @file -> $file {

    my %meta = Nebula::Grammar::Meta.parsefile( $file, :actions(Nebula::Grammar::Meta::Actions.new) ).ast;

    @!star.push: %meta;

  }

}

method star ( $name, $age = '', $core = 'x86_64', $form = 0, $tag = '' ) {

  my %star;

  %star.push: ( name => $name );
  %star.push: ( age  => $age )      if $age;
  %star.push: ( core => $core )     if $core;
  %star.push: ( form => $form.Int ) if $form;
  %star.push: ( tag  => $tag )      if $tag;

  my @candi = @!star.grep( * ≅ %star );

  @candi;
}

method stars ( ) {
  @!star;
}

multi infix:<≅> ( %left, %right --> Bool:D ) {

  return False unless %left<name> ~~ %right<name>;
  return False unless %left<age>  ~~ Version.new: %right<age> // '';
  return False unless %left<core> ~~ %right<core>;
  return False unless %left<form> ~~ %right<form>;
  return False unless %left<tag>  ~~ %right<tag>;

  True;
}
