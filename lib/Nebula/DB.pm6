use DB::SQLite;
unit role Nebula::DB;

has $!db;

submethod TWEAK ( ) {

  $!db = DB::SQLite.new: filename => '/var/nebula/nebula.db';
  self!init-db;

}

method !select-star ( $name, $age?, $core?, $form?, $tag? ) {

  my %star;

  %star.push: ( name => $name );
  %star.push: ( age  => $age )      if $age;
  %star.push: ( core => $core )     if $core;
  %star.push: ( form => $form.Int ) if $form;
  %star.push: ( tag  => $tag )      if $tag;


  my @star = $!db.query( 'select * from star where name = $name', :$name).hashes
    .grep( * ≅ %star )
    .map({ .push: ( cluster => self!select-cluster: .<star> ) })
    .map({ .push: ( law     => self!select-law:     .<star> ) })
    .map({ .push: ( env     => self!select-env:     .<star> ) });

  @star;
}


method !all-stars ( ) {

  my @star = $!db.query( 'select * from star' ).hashes
    .map({ .push: ( cluster => self!select-cluster: .<star> ) })
    .map({ .push: ( law     => self!select-law:     .<star> ) })
    .map({ .push: ( env     => self!select-env:     .<star> ) }) ;

  @star;
}


method !select-cluster ( Str:D $star ) {

  $!db.query( 'select name, age, core, form, tag from cluster where star = $star', $star).hashes;

}

method !select-law ( Str:D $star ) {

  $!db.query( 'select law from law where star = $star', $star).arrays.flat;

}

method !select-env ( Str:D $star ) {

  $!db.query( 'select env from env where star = $star', $star).arrays.flat;

}

method add-star (

  Str:D :$star!,
  Str:D :$name!,
  Str:D :$age!,
  Str:D :$core!,
  Int:D :$form!,
  Str:D :$tag!,
  Str:D :$source!,
  Str   :$desc,
  Str   :$location,
        :@cluster,
        :@law,
        :@env,

) {

  $!db.query(
    'insert into star ( star, name, age, core, form, tag, source, desc, location )
      values ( $star, $name, $age, $core, $form, $tag, $source, $desc, $location )',
      :$star, :$name, :$age, :$core, :$form, :$tag, :$source, :$desc, :$location
  );


    $!db.query(
      'insert into cluster ( star, name, age, core, form, tag )
        values ( $star, $name, $age, $core, $form, $tag )',
        |$_, :$star
    ) for @cluster;


  $!db.query( 'insert into law ( star, law ) values ( $star, $law )', law => $_, :$star) for @law;

  $!db.query( 'insert into env ( star, env ) values ( $star, $env )', env => $_, :$star) for @env;

}

method !init-db ( ) {
  $!db.execute: q:to /SQL/;
    PRAGMA foreign_keys = ON
    SQL

  $!db.execute: q:to /SQL/;
    create table if not exists star (
      star     text primary key not null,
      name     text,
      age      text,
      core     text,
      form     int,
      tag      text,
      source   text,
      desc     text,
      location text,
      chksum   text
    )
    SQL

  $!db.execute: q:to /SQL/;
    create table if not exists cluster (
      name text,
      age  text,
      core text,
      form int,
      tag  text,
      star text references star(star) ON DELETE CASCADE
    )
    SQL

  $!db.execute: q:to /SQL/;
    create table if not exists law (
      law  text,
      star text references star(star) ON DELETE CASCADE
    )
    SQL

  $!db.execute: q:to /SQL/;
    create table if not exists env (
      env  text,
      star text references star(star) ON DELETE CASCADE

    )
    SQL

}

multi infix:<≅> ( %left, %right --> Bool:D ) {

  return False unless %left<name> ~~ %right<name>;
  return False unless Version.new(%left<age>) ~~ Version.new(%right<age> // '');
  return False unless %left<core> ~~ %right<core>;
  return False unless %left<form> ~~ %right<form>;
  return False unless %left<tag>  ~~ %right<tag>;

  True;
}

