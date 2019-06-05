#!/usr/bin/env perl6

use lib <lib>;

use Nebula::Grammar::Proto;


my $proto = 'proto/coreutils/coreutils-8.31-x86_64-0-helix.proto'.IO;

my $actions = Nebula::Grammar::Proto::Actions.new;

my $parser = Nebula::Grammar::Proto.new;

#my $m = $parser.parsefile($proto, :$actions);
my $m = $parser.parsefile($proto);

#say $m.ast;
say $m;

