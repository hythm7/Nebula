#!/usr/bin/env perl6
#
use Galaxy::Grammar::Star;

use lib 'lib';
use Nebula;

multi MAIN ( 'form', Str $star ) {

  my $parser  = Galaxy::Grammar::Star;
  my $actions = Galaxy::Grammar::Star::Actions.new;
  my $m       = $parser.parse( $star, :$actions );

  fail "Can not parse star $star" unless $m;

  my %star = $m.ast;
  Nebula.new.form: :%star;

}

multi MAIN ( 'serve' ) {

  Nebula.new.serve;

}
