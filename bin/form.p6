#!/usr/bin/env perl6
#
use lib 'lib';
use Nebula;

multi MAIN ( Str :$star ) {

  Nebula.new.form: :$star;

}

multi MAIN ( Str $proto where *.IO.e ) {

  Nebula.new.form: $proto.IO;

}
