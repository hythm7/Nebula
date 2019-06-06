#!/usr/bin/env perl6
#
use lib 'lib';
use Nebula::Grammar::Proto;

multi MAIN ( Str $file ) {

  my $parser  = Nebula::Grammar::Proto;
  my $actions = Nebula::Grammar::Proto::Actions.new;

  my %proto = $parser.parsefile( $file, :$actions ).ast;

  say %proto;
}
