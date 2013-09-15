use warnings;
use strict;
use Test::More;
use Test::Mojo;

plan skip_all => 'Not ready for alien host' unless $^O eq 'linux';

{
  use Mojolicious::Lite;
  plugin 'AssetPack' => { minify => 1, rebuild => 1, no_autodetect => 1 };

  app->asset->preprocessors->add(js => sub {
    my($assetpack, $text, $file) = @_;
    $$text = 'var too = "cool";';
  });
  app->asset('app.js' => '/js/a.js');

  get '/js' => 'js';
}

plan skip_all => 't/public/packed' unless -d 't/public/packed';

my $t = Test::Mojo->new;
my $ts = $^T;

{
  $t->get_ok('/js'); # trigger pack_javascripts() twice for coverage
  $t->get_ok('/js')
    ->status_is(200)
    ->content_like(qr{<script src="/packed/app\.$ts\.js".*}m)
    ;
  $t->get_ok("/packed/app.$ts.js")->status_is(200)->content_is('var too = "cool";');
}

done_testing;
__DATA__
@@ js.html.ep
%= asset 'app.js'
@@ less.html.ep
%= asset 'less.css'
@@ sass.html.ep
%= asset 'sass.css'
@@ css.html.ep
%= asset 'app.css'