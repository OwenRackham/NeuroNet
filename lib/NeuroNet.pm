package NeuroNet;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
  $r->get('/modules')->to('example#modules');
  $r->get('/genes')->to('example#genes');
  $r->get('/modulenet')->to('example#moduleNet');
  $r->get('/moduletabledenovo')->to('example#moduleTableDenovo');
  $r->get('/moduletableGWAS')->to('example#moduleTableGWAS');
}

1;
