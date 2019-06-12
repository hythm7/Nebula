#!/usr/bin/env perl6

use lib 'lib';
use Nebula::Cloud;
use Nebula::Routes;

multi MAIN ( 'form', Str $star ) {

  Nebula::Cloud.new.form: :$star;

}

multi MAIN ( 'blackhole', Str $star ) {

  Nebula::Cloud.new.blackhole: :$star;

}

multi MAIN ( 'serve', Str:D :$host = 'localhost', Int:D :$port = 7777 ) {

  Nebula::Routes.new( :$host, :$port ).serve;

}
