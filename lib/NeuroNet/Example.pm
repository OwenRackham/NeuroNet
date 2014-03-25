package NeuroNet::Example;
use Mojo::Base 'Mojolicious::Controller';
use DBI;
# This action will render a template
sub welcome {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to NBIGN');
}

sub modules {
  my $self = shift;
  my $module = $self->param('module');
  unless(defined($module)){
		$module = 1;
	}
  my $strength = $self->param('strength');
  unless(defined($strength)){
		$strength = 500;
	}
  
  # Render template "example/welcome.html.ep" with message
  $self->stash(module=>$module);
  $self->stash(strength=>$strength);
  $self->render(msg => 'Modules in NBIGN: Module $module');
}

sub moduleNet {
  my $self = shift;
  my $module = $self->param('module');
  unless(defined($module)){
		$module = 1;
	}
 	my $type = $self->param('type');
  unless(defined($type)){
		$type = 'STRING';
	}
  my $strength = $self->param('strength');
  unless(defined($strength)){
		$strength = 500;
	}
	my $network;
	if($type eq 'STRING'){
 		$network = getModuleNet($module,$strength);
	}elsif($type eq 'DAPPLE'){
		$network = getDAPPLENet($module);
	}elsif($type eq 'CoExp'){
		$network = getCoExpNet($module);
	}
  # Render template "example/welcome.html.ep" with message
  $self->render(json => {data => $network}  );
}



sub moduleTableDenovo {
  my $self = shift;
  my $module = $self->param('module');
  unless(defined($module)){
		$module = 1;
	}
  my $data = getModuleTableDenovo($module);
  # Render template "example/welcome.html.ep" with message
  $self->render(json => {data => $data}  );
}

sub moduleTableGWAS {
  my $self = shift;
  my $module = $self->param('module');
  unless(defined($module)){
		$module = 1;
	}
  my $data = getModuleTableGWAS($module);
  # Render template "example/welcome.html.ep" with message
  $self->render(json => {data => $data}  );
}

sub getModuleGenes {
    my $module = shift;
    my $dbh = DBConnect('SNPs');
	my $sth =   $dbh->prepare( "select KirMod.Symbol from KirMod where Cluster = ?;"); 
	$sth->execute($module);
	my %genes;
    while (my @temp = $sth->fetchrow_array ) {
		$genes{$temp[0]} = 1;
		
	}
    return \%genes;
}

sub getModuleNet {
    my $module = shift;
    my $strength = shift;
    my $dbh = DBConnect('SNPs');
	my $sth =   $dbh->prepare( "select a.Symbol,b.Symbol,strength from KirMod a,KirMod b,STRING_net where a.Ensembl_G_ID = STRING_net.source_ENSG and b.Ensembl_G_ID = STRING_net.target_ENSG and a.Cluster = $module and b.Cluster =$module;"); 
	$sth->execute();
	my %links;
	#{"name":"flare.animate.interpolate.PointInterpolator","size":1675,"imports":["flare.animate.interpolate.Interpolator"]},
    while (my @temp = $sth->fetchrow_array ) {
		push(@{$links{$temp[0]}},$temp[1]);
	}
	my $nodes = getModuleGenes($module);
	my @data;
	foreach my $gene1 (sort keys %$nodes){
		my %data;
		$data{'name'}=$gene1;
		$data{'size'}=100;
		if(exists($links{$gene1})){
			$data{'imports'}=$links{$gene1};
		}
		push(@data,\%data);	
	}
    return \@data;
}

sub getDAPPLENet {
    my $module = shift;
    my $dbh = DBConnect('SNPs');
	my $sth =   $dbh->prepare( "select source_Symbol,target_Symbol from DAPPLE_net where Cluster = ?;"); 
	$sth->execute($module);
	my %links;
	#{"name":"flare.animate.interpolate.PointInterpolator","size":1675,"imports":["flare.animate.interpolate.Interpolator"]},
    while (my @temp = $sth->fetchrow_array ) {
		push(@{$links{$temp[0]}},$temp[1]);
	}
	my $nodes = getModuleGenes($module);
	my @data;
	foreach my $gene1 (sort keys %$nodes){
		my %data;
		$data{'name'}=$gene1;
		$data{'size'}=100;
		if(exists($links{$gene1})){
			$data{'imports'}=$links{$gene1};
		}
		push(@data,\%data);	
	}
    return \@data;
}

sub getCoExpNet {
    my $module = shift;
    my $nodes = getModuleGenes($module);
    my %nodes = %{$nodes};
    my $dbh = DBConnect('SNPs');
	my $sth =   $dbh->prepare( "select source_Symbol,target_Symbol from CoExpNet where Cluster = ? and stength > 0.8;"); 
	$sth->execute($module);
	my %links;
    while (my @temp = $sth->fetchrow_array ) {
    	if(exists($nodes{$temp[1]})){
			push(@{$links{$temp[0]}},$temp[1]);
    	}
	}
	
	my @data;
	foreach my $gene1 (sort keys %$nodes){
		my %data;
		$data{'name'}=$gene1;
		$data{'size'}=100;
		if(exists($links{$gene1})){
			$data{'imports'}=$links{$gene1};
		}
		push(@data,\%data);	
	}
    return \@data;
}

sub getModuleTableDenovo {
    my $module = shift;
    my $dbh = DBConnect('SNPs');
	my $sth =   $dbh->prepare( "select KirMod.Symbol,Type,Author,Disease from KirMod,denovo where KirMod.Symbol = denovo.Symbol and Cluster = ? order by Symbol;"); 
	$sth->execute($module);
	my @table;
	my @list;
    while (my @temp = $sth->fetchrow_array ) {
		push(@table,\@temp);
		push(@list,$temp[0]);
	}
	my %data;
	$data{'table'}=\@table;
	$data{'list'}=\@list;
    return \%data;
}

sub getModuleTableGWAS {
    my $module = shift;
    my $dbh = DBConnect('SNPs');
	my $sth =   $dbh->prepare( "select distinct(KirMod.Symbol),disorder,adjP,minP from KirMod,GWAS,KirMap where KirMod.Symbol = GWAS.Symbol and GWAS.ENSG = KirMap.ENSG and adjP < 0.05 and Cluster = ? order by adjP asc;"); 
	$sth->execute($module);
	my @table;
	my @list;
    while (my @temp = $sth->fetchrow_array ) {
		push(@table,\@temp);
		push(@list,$temp[0]);
	}
	my %data;
	$data{'table'}=\@table;
	$data{'list'}=\@list;
    return \%data;
}


sub DBConnect {
    my $database = shift || 'SNPs';
	my $user = shift || 'orackham';
	my $password = 'blank';
    my $dsn = "DBI:mysql:SNPs:localhost:";
my $dbh;
	if($password eq 'blank'){
$dbh = DBI->connect( $dsn, "$user");
	}else{ 

   $dbh = DBI->connect( $dsn, "rackham" );
}
    return $dbh;
}



1;
