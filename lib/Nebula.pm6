use Nebula::Grammar::Meta;
use Nebula::Star;

unit class Nebula;

has Str          $.name;
has IO           $.origin;
has Nebula::Star @!star;

method TWEAK ( ) {

  # Temporary
  my $raku001 = Nebula::Star.new: :name('raku'), :age(Version.new: '0.0.1'), :core('x86_64'), :form(0), :tag('glx');
  my $raku002 = Nebula::Star.new: :name('raku'), :age(Version.new: '0.0.2'), :core('x86_64'), :form(1);
  my $dovy001 = Nebula::Star.new: :name('dovy'), :age(Version.new: '0.0.1'), :core('x86_64'), :form(0);
  my $dovy002 = Nebula::Star.new: :name('dovy'), :age(Version.new: '0.0.2'), :core('x86_64'), :form(1);
  my $nimo001 = Nebula::Star.new: :name('nimo'), :age(Version.new: '0.0.1'), :core('x86_64'), :form(0);
  my $nimo002 = Nebula::Star.new: :name('nimo'), :age(Version.new: '0.0.2'), :core('x86_64'), :form(1), :tag('glx');

  @!star = $raku001, $raku002, $dovy001, $dovy002, $nimo001, $nimo002;


}

method star ( $name, $age?, $core?, $form?, $tag? ) {

  my %star;
  %star.push: ( name => $name);
  %star.push: ( age  => Version.new: $age ) if $age;
  %star.push: ( core => $core )             if $core;
  %star.push: ( form => $form.Int )         if $form;
  %star.push: ( tag  => $tag )              if $tag;

  my $star = Nebula::Star.new: |%star;

  my @candi = @!star.grep( * eqv $star );

  @candi .= map: &serialize;

  @candi;
}

method stars ( ) {
  @!star.map: &serialize;
}

multi infix:<eqv> ( Nebula::Star $left, Nebula::Star $right --> Bool ) {

  return False unless $left.name ~~ $right.name;
  return False unless $left.age  ~~ $right.age;
  return False unless $left.core ~~ $right.core;
  return False unless $left.form ~~ $right.form;
  return False unless $left.tag  ~~ $right.tag;

  True;
}

sub serialize ( Nebula::Star $star ) {

  {
   name => $star.name.Str,
   age  => $star.age.Str,
   core => $star.core.Str,
   form => $star.form.Int,
   tag  => $star.tag
  }

}
