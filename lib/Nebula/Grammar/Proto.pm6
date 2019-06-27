no precompilation;
#use Grammar::Tracer;

use Cro::Uri;
use Galaxy::Grammar::Star;

grammar Nebula::Grammar::Proto {
  also is Galaxy::Grammar::Star;

  token TOP { <sections> }

  token sections { <.ws> <section>* %% <.nl> }

  proto rule section { * }
  rule section:sym<proto>     { <.lt> <sym> <.gt> <.nl> <proto>*    % <.nl> }
  rule section:sym<cluster>   { <.lt> <sym> <.gt> <.nl> <starname>* % <.nl> }
  rule section:sym<configure> { <.lt> <sym> <.gt> <.nl> <cmd>+      % <.nl> }
  rule section:sym<compile>   { <.lt> <sym> <.gt> <.nl> <cmd>+      % <.nl> }
  rule section:sym<install>   { <.lt> <sym> <.gt> <.nl> <cmd>+      % <.nl> }
  rule section:sym<desc>      { <.lt> <sym> <.gt> <.nl> <desc>               }

  proto rule proto { * }
  rule proto:sym<star>     { <.ws> <sym> <starname> }
  rule proto:sym<source>   { <.ws> <sym> <uri> }
  rule proto:sym<srcdir>   { <.ws> <sym> <path> }


  token cmd { <!before \s> <-[<>;]>+ <.semicolon> <!after \s> }

  token desc { <-[<>]>+ }

  token uri { <.alpha>+ <colon> <slash> <slash> <hostname> [ <colon> <digit>+ ]? <slash>? <path>? }

  token nl { [ <comment>? \h* \n ]+ }

  token comment { \h* '#' \N* }

  token hostname { (\w+) ( <dot> \w+ )* }
  token path { <[ a..z A..Z 0..9 \-_.!~*'():@&=+$,/ ]>+ }

  token semicolon { ';' }
  token colon { ':' }
  token slash { '/' }
  token lt  { '<' }
  token gt  { '>' }
  token ws  { \h* }
}


class Nebula::Grammar::Proto::Actions {
  also is Galaxy::Grammar::Star::Actions;

  has %!proto;


  method TOP ( $/ ) { make %!proto; }

  method proto:sym<star>     ( $/ ) { %!proto.push: ( $<starname>.ast ) }
  method proto:sym<source>   ( $/ ) { %!proto.push: ( $<sym>.Str => $<uri>.Str ) }
  method proto:sym<srcdir>  ( $/ ) { %!proto.push: ( $<sym>.Str => $<path>.IO ) }
  method proto:sym<builddir> ( $/ ) { %!proto.push: ( $<sym>.Str => $<path>.IO ) }

  method section:sym<cluster>   ( $/ ) { %!proto.push: ( $<sym>.Str => $<starname>».ast ) }
  method section:sym<desc>      ( $/ ) { %!proto.push: ( $<sym>.Str => $<desc>.Str ) }
  method section:sym<compile>   ( $/ ) { %!proto.push: ( $<sym>.Str => $<cmd>>>.Str ) }
  method section:sym<configure> ( $/ ) { %!proto.push: ( $<sym>.Str => $<cmd>>>.Str ) }
  method section:sym<install>   ( $/ ) { %!proto.push: ( $<sym>.Str => $<cmd>>>.Str ) }

}


