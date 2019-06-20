no precompilation;

use Cro::Uri;
use Galaxy::Grammar::Star;

grammar Nebula::Grammar::Proto {
  also is Galaxy::Grammar::Star;

  token TOP { <sections> }

  token sections { <.ws> <section>* %% <.nl> }

  proto rule section { * }
  rule section:sym<proto>     { <.lt> <sym> <.gt> <.nl> <proto>*     % <.nl> }
  rule section:sym<cluster>   { <.lt> <sym> <.gt> <.nl> <starname>*  % <.nl> }
  rule section:sym<configure> { <.lt> <sym> <.gt> <.nl> <configure>* % <.nl> }
  rule section:sym<make>      { <.lt> <sym> <.gt> <.nl> <make>*      % <.nl> }
  rule section:sym<install>   { <.lt> <sym> <.gt> <.nl> <install>*   % <.nl> }
  rule section:sym<desc>      { <.lt> <sym> <.gt> <.nl> <desc>               }

  proto rule proto { * }
  rule proto:sym<star>     { <.ws> <sym> <starname> }
  rule proto:sym<source>   { <.ws> <sym> <uri> }
  rule proto:sym<srcname>  { <.ws> <sym> <name> }
  rule proto:sym<srcage>   { <.ws> <sym> <age> }
  rule proto:sym<builddir> { <.ws> <sym> <path> }

  proto rule configure { * }
  rule configure:sym<env> { <.ws> <sym> <law> }
  rule configure:sym<cmd> { <.ws> <sym> <law> }
  rule configure:sym<law> { <.ws> <law> }

  proto rule make { * }
  rule make:sym<cmd>  { <.ws> <sym> <value> }
  rule make:sym<what> { <.ws> <sym> <value> }

  proto rule install { * }
  rule install:sym<cmd>   { <.ws> <sym> <value> }
  rule install:sym<what>  { <.ws> <sym> <value> }
  rule install:sym<where> { <.ws> <sym> <value> }


  proto rule law { * }
  rule law:sym<kv>  { <.ws> <key> <value> }
  rule law:sym<key> { <.ws> <key> }

  rule env { <key> <value> }

  token desc { <-[<>]>+ }

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

  has %!proto;


  method TOP ( $/ ) { make %!proto; }

  method proto:sym<star>     ( $/ ) { %!proto.push: ( $<starname>.ast ) }
  method proto:sym<source>   ( $/ ) { %!proto.push: ( $<sym>.Str => $<uri>.Str ) }
  method proto:sym<srcname>  ( $/ ) { %!proto.push: ( $<sym>.Str => $<name>.Str ) }
  method proto:sym<srcage>   ( $/ ) { %!proto.push: ( $<sym>.Str => $<age>.Str ) }
  method proto:sym<builddir> ( $/ ) { %!proto.push: ( $<sym>.Str => $<path>.IO ) }

  method configure:sym<env> ( $/ ) { %!proto<configure><env>.push: $<law>.ast  }
  method configure:sym<cmd> ( $/ ) { %!proto<configure><cmd>.push: $<law>.ast  }
  method configure:sym<law> ( $/ ) { %!proto<configure><law>.push: $<law>.ast  }

  method make:sym<cmd>  ( $/ ) { %!proto<make><cmd>.push:  $<value>.Str  }
  method make:sym<what> ( $/ ) { %!proto<make><what>.push: $<value>.Str  }

  method install:sym<cmd>   ( $/ ) { %!proto<install><cmd>.push:   $<value>.Str  }
  method install:sym<what>  ( $/ ) { %!proto<install><what>.push:  $<value>.Str  }
  method install:sym<where> ( $/ ) { %!proto<install><where>.push: $<value>.Str  }

  method section:sym<cluster>   ( $/ ) { %!proto.push: ( $<sym>.Str => $<starname>».ast ) }
  method section:sym<desc>      ( $/ ) { %!proto.push: ( $<sym>.Str => $<desc>.Str ) }


  method law:sym<key> ( $/ ) { make "$<key>" }
  method law:sym<kv>  ( $/ ) { make "$<key>=$<value>" }

}


