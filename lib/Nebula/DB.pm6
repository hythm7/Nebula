use DB::SQLite;
unit role Nebula::DB;

has $!db;

submethod TWEAK ( ) {

  $!db = DB::SQLite.new: filename => '/var/nebula/nebula.db';
  self!init-db;

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

  @cluster.map( -> %cluster {

    $!db.query(
      'insert into cluster ( star, name, age, core, form, tag )
        values ( $star, $name, $age, $core, $form, $tag )',
        |%cluster, :$star
    );

  });

  $!db.query( 'insert into law ( star, law ) values ( $star, $law )', law => $_, :$star) for @law;

  $!db.query( 'insert into env ( star, env ) values ( $star, $env )', env => $_, :$star) for @env;

}

method !init-db ( ) {
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
      star text references star(star),
      name text,
      age  text,
      core text,
      form int,
      tag  text
    )
    SQL

  $!db.execute: q:to /SQL/;
    create table if not exists law (
      star text references star(star),
      law  text
    )
    SQL

  $!db.execute: q:to /SQL/;
    create table if not exists env (
      star text,
      env  text
    )
    SQL

}

