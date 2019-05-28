use Cro::Uri;
use Galaxy::Grammar::Star;

grammar Nebula::Grammar::Meta {
  also does Galaxy::Grammar::Star;

  token TOP { <sections> }

  token sections { <.ws> <section>* %% <.nl> }

  proto rule section { * }
  rule section:sym<main>    { <lt> <starname> <gt> <.nl> <main>+     % <.nl> }
  rule section:sym<cluster> { <lt> <sym>      <gt> <.nl> <starname>* % <.nl> }

  proto rule main { * }
  rule main:sym<chksum>   { <.ws> <sym> <chksum> }
  rule main:sym<location> { <.ws> <sym> <uri> }

  token uri { <alpha>+ <colon> <slash> <slash> <hostname> [ <colon> <digit>+ ]? <slash>? <path>? }
  token chksum  { <.alnum> ** 32 }

  token nl { [ <comment>? \h* \n ]+ }

  token comment { \h* '#' \N* }

  token hostname { (\w+) ( <dot> \w+ )* }
  token path { <[ a..z A..Z 0..9 \-_.!~*'():@&=+$,/ ]>+ }

  token colon { ':' }
  token slash { '/' }
  token lt  { '<' }
  token gt  { '>' }
  token ws  { \h* }
}


class Nebula::Grammar::Meta::Actions {
  also does Galaxy::Grammar::Star::Actions;

  has %!meta;


  method TOP ( $/ ) { make %!meta; }

  method section:sym<main>    ( $/ ) {
    %!meta.push: $<starname>.ast;
    %!meta.push: $<main>».ast;
  }

  method section:sym<cluster> ( $/ ) { %!meta.push: ( cluster => $<starname>».ast ) }

  method main:sym<chksum>   ( $/ ) { make $<sym>.Str => $<chksum>.Str }
  method main:sym<location> ( $/ ) { make $<sym>.Str => Cro::Uri.new: uri => $<uri>.Str }

}


