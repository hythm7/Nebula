#no precompilation;
#use Grammar::Tracer;
use Cro::Uri;
use Galaxy::Grammar::Star;

grammar Nebula::Grammar::Proto {
  also is Galaxy::Grammar::Star;

  token TOP { <sections> }

  token sections { <.ws> <section>* %% <.nl> }

  proto rule section { * }
  rule section:sym<proto>   { <.lt> <sym> <.gt> <.nl> <proto>*    % <.nl> }
  rule section:sym<law>     { <.lt> <sym> <.gt> <.nl> <law>*      % <.nl> }
  rule section:sym<env>     { <.lt> <sym> <.gt> <.nl> <env>*      % <.nl> }
  rule section:sym<cluster> { <.lt> <sym> <.gt> <.nl> <starname>* % <.nl> }
  #rule section:sym<desc> { <.lt> <sym> <.gt> <.nl> <desc>           }
  #rule section:sym<postgrv> { <.lt> <sym> <.gt> <.nl> <postgrv> }
 # rule section:sym<preblk>  { <lt> <sym> <gt> <.nl> <preblk>  % <.nl> }

  proto rule proto { * }
  rule proto:sym<star>   { <.ws> <sym> <starname> }
  rule proto:sym<source> { <.ws> <sym> <uri> }

  proto rule law { * }
  rule law:sym<kv>  { <.ws> <key> <value> }
  rule law:sym<key> { <.ws> <key> }

  rule env { <key> <value> }

  #token desc { <-[<>]>+ }

  token key   { <!before \s> <-[\n\s<>;]>+ <!after \s> }
  token value { <!before \s> <-[\n;<>]>+   <!after \s> }

  token uri { <.alpha>+ <colon> <slash> <slash> <hostname> [ <colon> <digit>+ ]? <slash>? <path>? }

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


class Nebula::Grammar::Proto::Actions {
  also is Galaxy::Grammar::Star::Actions;

  has %!meta;


  method TOP ( $/ ) { make %!meta; }

  method proto:sym<star>   ( $/ ) { %!meta.push: ( $<starname>.ast ) }
  method proto:sym<source> ( $/ ) { %!meta.push: ( $<sym>.Str => Cro::Uri.parse: $<uri> ) }

  method section:sym<law>     ( $/ ) { %!meta.push: ( $<sym>.Str => $<law>».ast ) }
  method section:sym<env>     ( $/ ) { %!meta.push: ( $<sym>.Str => $<env>».ast ) }
  method section:sym<cluster> ( $/ ) { %!meta.push: ( $<sym>.Str => $<starname>».ast ) }
  #method section:sym<desc> ( $/ ) { %!meta.push: ( $<sym>.Str => $<desc>.Str ) }


  method law:sym<key> ( $/ ) { make "--$<key>" }
  method law:sym<kv>  ( $/ ) { make "--$<key>=$<value>" }

  method env ( $/ ) { make "$<key>=$<value>" }

}


