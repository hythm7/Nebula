#!/usr/bin/env perl6

use lib <lib>;

use Nebula::Grammar::Meta;


my $meta = 'meta/raku.meta'.IO;

my $actions = Nebula::Grammar::Meta::Actions.new;

my $parser = Nebula::Grammar::Meta.new;

my $m = $parser.parsefile($meta, :$actions);

say $m.ast;

