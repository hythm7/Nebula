#!/usr/bin/env perl6

use lib <lib>;

use Nebula::Grammar::Proto;


my $proto = 'proto/acl/acl-2.2.53-x86_64-0-helix/proto'.IO;

my $actions = Nebula::Grammar::Proto::Actions.new;

my $parser = Nebula::Grammar::Proto.new;

my $m = $parser.parsefile($proto, :$actions);
say $m.ast<compile>;
