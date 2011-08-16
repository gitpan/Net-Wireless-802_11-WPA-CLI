package Net::Wireless::802_11::WPA::CLI;

use warnings;
use strict;

=head1 NAME

Net::Wireless::802_11::WPA::CLI - Provides a interface to wpa_cli.

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';


=head1 SYNOPSIS

    use Net::Wireless::802_11::WPA::CLI;

    my $foo = Net::Wireless::802_11::WPA::CLI->new();
    ...

=head1 FUNCTIONS

=head2 new

This initializes the object to be used for making use of wpa_cli.

It takes no arguements and returns undef upon failure.

=cut

sub new {
	#tests if it is usable.
	my $status=`wpa_cli status`;
	if (!$? == 0){
		warn("wpa_cli failed with '".$status."'");
		return undef;
	};

	my %statusH=status_breakdown($status);
	if (!defined($status)){
		return undef;
	};
	
	my $self = {status=>{%statusH}};
	
	
	bless $self;

	bless $self;
	return $self;
}

=head2 status

This function gets the current status from wpa_cli.

It takes no arguements and returns undef upon failure.

=cut

sub status{
	my ($self, $statusS)= @_;

	my $status=`wpa_cli status`;
	if (!$? == 0){
		warn("wpa_cli failed with '".$status."'");
		return undef;
	}
	
	my %statusH=status_breakdown($status);
	if (!defined($status)){
		return undef;
	}
	
	$self->{status}={%statusH};
	
	return %statusH;
}

=head2 save_config

This saves the current configuration. The user requesting this
does not need write permissions to file being used 

It takes no arguements and returns undef upon failure.

=cut

sub save_config{
	my ($self)= @_;

	return $self->run_TF_command('save_config');
}

=head2 reassociate

This saves the current configuration. The user requesting this
does not need write permissions to file being used 

It takes no arguements and returns undef upon failure.

=cut

sub reassociate{
	my ($self)= @_;

	return $self->run_TF_command('reassociate');
}

=head2 set_network

	$return=$obj->set_network($networkID, $variable, $value)

This sets a variable for for a specific network ID.

The return of undef indicates a error with running wpa_cli, other wise
it is a true or false for if it worked.

=cut

sub set_network{
	my ($self, $nid, $variable, $value)= @_;

	#return if the netword ID is not numeric.
	if ($nid =~ /[0123456789]*/){
		warn('non-numeric network ID used');
		return undef;
	}

	return $self->run_TF_command('set_network '.$nid.' '.$variable.' '.$value, 0);
}

=head2 get_network

	$return=$obj->get_network($networkID, $variable)

This gets a variable for for a specific network ID.

The return of undef indicates a error with running wpa_cli or a failure
is returned. Otherwise it is what ever the variable was set to.

=cut

sub get_network{
	my ($self, $nid, $variable)= @_;

	#return if the netword ID is not numeric.
	if ($nid =~ /[0123456789]*/){
		warn('non-numeric network ID used');
		return undef;
	}

	my $returned=$self->run_command('get_network '.$nid.' '.$variable);

	#this means there was a error running wpa_cli
	if(!defined($returned)){
		return undef;
	}

	#this means it failed
	if ($returned =~ /.*\nFAIL\n/){
		return undef;
	}
	
	#remove the first line.
	$returned=~s/.*\n//;
	
	#remove ^" and "$, which will be useful for SSID and possibly some others.
	$returned=~s/^"//;
	$returned=~s/^#//;
	
	return $returned;
}

=head2 pin

	$return=$obj->pin($networkID, $value)

This sets the pin for a network.

The return of undef indicates a error with running wpa_cli  or non-numeric
network ID, other wise it is a true or false for if it worked.

=cut

sub pin{
	my ($self, $nid, $value)= @_;

	#return if the netword ID is not numeric.
	if ($nid =~ /[0123456789]*/){
		warn('non-numeric network ID used');
		return undef;
	}

	return $self->run_TF_command('pin '.$nid.' '.$value, 0);
}

=head2 new_password

	$return=$obj->new_password($networkID, $value)

This sets a new password for a network.

The return of undef indicates a error with running wpa_cli or non-numeric
network ID, other wise it is a true or false for if it worked.

=cut

sub new_password{
	my ($self, $nid, $value)= @_;

	#return if the netword ID is not numeric.
	if ($nid =~ /[0123456789]*/){
		warn('non-numeric network ID used');
		return undef;
	}

	return $self->run_TF_command('new_password '.$nid.' '.$value, 0);
}

=head2 add_network

	$return=$obj->add_network()

This adds a network.

The returned value is the numeric ID of the new network. A
return of UNDEF indicates some error.

=cut

sub add_network{
	my ($self)= @_;


	my $returned=$self->run_command('add_network');

	#this means there was a error running wpa_cli
	if(!defined($returned)){
		return undef;
	}

	#this means it failed
	if ($returned =~ /.*\nFAIL\n/){
		return undef;
	}
	
	#remove the first line.
	$returned=~s/.*\n//;
	
	chomp($returned);
	
	return $returned;
}

=head2 remove_network

	$return=$obj->remove_network($networkID)

This sets a one-time-password a network.

The return of undef indicates a error with running wpa_cli or
non-numeric network ID, other wise it is a true or false for if
it worked.

=cut

sub remove_network{
	my ($self, $nid)= @_;

	#return if the netword ID is not numeric.
	if ($nid =~ /[0123456789]*/){
		warn('non-numeric network ID used');
		return undef;
	}

	return $self->run_TF_command('remove_network '.$nid, 0);
}

=head2 select_network

	$return=$obj->select_network($networkID)

This is the network ID to select, while disabling the others.

The return of undef indicates a error with running wpa_cli or
a non-numeric network ID, other wise it is a true or false for
if it worked.

=cut

sub select_network{
	my ($self, $nid)= @_;

	#return if the netword ID is not numeric.
	if ($nid =~ /[0123456789]*/){
		warn('non-numeric network ID used');
		return undef;
	}

	return $self->run_TF_command('select_network '.$nid, 0);
}

=head2 enable_network

	$return=$obj->enable_network($networkID)

This enables a network ID.

The return of undef indicates a error with running wpa_cli or
a non-numeric network ID, other wise it is a true or false for
if it worked.

=cut

sub enable_network{
	my ($self, $nid)= @_;

	#return if the netword ID is not numeric.
	if ($nid =~ /[0123456789]*/){
		warn('non-numeric network ID used');
		return undef;
	}

	return $self->run_TF_command('enable_network '.$nid, 0);
}

=head2 disable_network

	$return=$obj->disable_network($networkID)

This disables a network ID.

The return of undef indicates a error with running wpa_cli or
a non-numeric network ID, other wise it is a true or false for
if it worked.

=cut

sub disable_network{
	my ($self, $nid)= @_;

	#return if the netword ID is not numeric.
	if ($nid =~ /[0123456789]*/){
		warn('non-numeric network ID used');
		return undef;
	}

	return $self->run_TF_command('disable_network '.$nid, 0);
}

=head2 reconfigure

	$return=$obj->reconfigure($networkID)

This causes wpa_supplicant to reread it's configuration file.

The return of undef indicates a error with running wpa_cli,
other wise it is a true or false for if it worked.

=cut

sub reconfigure{
	my ($self)= @_;


	return $self->run_TF_command('reconfigure', 0);
}

=head2 preauthenticate

	$return=$obj->preauthenticate($BSSID)

Force preauthentication for a BSSID.

The return of undef indicates a error with running wpa_cli or
a non-numeric network ID, other wise it is a true or false for
if it worked.

=cut

sub preauthenticate{
	my ($self, $bssid)= @_;

	return $self->run_TF_command('preauthenticate '.$bssid, 0);
}

=head2 disconnect

	$return=$obj->disconnect()

Disconnect and wait for a reassosiate command.

The return of undef indicates a error with running wpa_cli or
a non-numeric network ID, other wise it is a true or false for
if it worked.

=cut

sub disconnect{
	my ($self, $bssid)= @_;

	return $self->run_TF_command('disconnect'. 0);
}

=head2 list_network

	%return=$obj->get_network($networkID, $variable)

This lists the configured networks.

The return of undef indicates a error with running wpa_cli or a failure
is returned. Otherwise a hash is returned.

They keys for the hash are the network IDs. The value of each is another hash.
It contians the SSID, BSSID, and flag. All keys are lower case.

=cut

sub list_network{
	my ($self, $nid, $variable)= @_;

	#return if the netword ID is not numeric.
	if ($nid =~ /[0123456789]*/){
		warn('non-numeric network ID used');
		return undef;
	}

	my $returned=$self->run_command('list_network');

	#this means there was a error running wpa_cli
	if(!defined($returned)){
		return undef;
	}

	#this means it failed
	if ($returned =~ /.*\nFAIL\n/){
		return undef;
	}
	
	my @returnedA=split(/\n/, $returned);
	
	#this will be returned
	my %hash=();
	
	my $returnedAint=2;
	while(defined($returnedA[$returnedAint])){
		#remove the extra spaces
		$returnedA[$returnedAint]=~s/ //g;
		
		chomp($returnedA[$returnedAint]);
		
		my @linesplit=split(/ /, $returnedA[$returnedAint]);
		
		#finally do something with the hash
		$hash{$linesplit[0]}={flag=>$linesplit[$#linesplit]};
		
		#get the bssid
		my $bssidInt=$#linesplit-1;
		$hash{$linesplit[0]}{bssid}=$linesplit[$bssidInt];

		#rebuild the ssid part
		my $ssidInt=1;
		my $ssidIntMax=$bssidInt-1;
		$hash{$linesplit[$linesplit[0]]}{ssid}="";
		while($ssidInt <= $ssidIntMax){
			$hash{$linesplit[$linesplit[0]]}{ssid}=
					$hash{$linesplit[$linesplit[0]]}{ssid}.$linesplit[$ssidInt];
			
			$ssidInt++;
		}
	}
	
	return %hash;
}

=head2 mib

	%return=$obj->get_network($networkID, $variable)

This lists the configured networks.

The return of undef indicates a error with running wpa_cli or a failure
is returned. Otherwise a hash is returned.

They keys for the hash are the network IDs. The value of each is another hash.
It contians the SSID, BSSID, and flag. All keys are lower case.

=cut

sub mib{
	my ($self, $nid, $variable)= @_;

	#return if the netword ID is not numeric.
	if ($nid =~ /[0123456789]*/){
		warn('non-numeric network ID used');
		return undef;
	}

	my $returned=$self->run_command('mib');

	#this means there was a error running wpa_cli
	if(!defined($returned)){
		return undef;
	}

	#this means it failed
	if ($returned =~ /.*\nFAIL\n/){
		return undef;
	}
	
	my %hash=status_breakdown($returned, 'mib');
	
	return %hash;
}

=head2 run_TF_command

	$returned=$obj->run_TF_command($command, 0)

This runs a arbirary command in which the expected values are
either 'FAIL' or 'OK'. This function is largely intended for internal
use by this module.

It takes two arguement. The first is string containing the command and any
arguements for it. The second is what to return on a unknown return.

UNDEF is returned upon with running wpa_cli. Other wise a per boolean value
is returned set to the corresponding success of the command.

=cut

sub run_TF_command{
	my ($self, $command, $onend)= @_;

	my $status=`wpa_cli $command`;
	if (!$? == 0){
		warn("wpa_cli failed with '".$status."'"."for '".$command."'");
		return undef;
	}

	#return 0 upon failure
	if ($status =~ /.*\nFAIL\n/){
		return 0;
	}

	#return 1 upon success
	if ($status =~ /.*\nOK\n/){
		return 1;
	}

	return $onend;
}

=head2 run_command

	$returned=$obj->run_command($command)

This runs a arbirary command in which. This function is largely intended for
internal use by this module.

It takes arguement, which is string containing the command and any
arguements for it.

UNDEF is returned upon with running wpa_cli. Otherwise the return is the return
from executed command.

=cut

sub run_command{
	my ($self, $command)= @_;

	my $status=`wpa_cli $command`;
	if (!$? == 0){
		warn("wpa_cli failed with '".$status."'"."for '".$command."'");
		return undef;
	}

	return $status;
}

=head2 status_breakdown

This is a internal function.

=cut

#this is a internal function used by this module
#It breaks down that return from status.
sub status_breakdown{
	my ($statusS, $type)= @_;
	
	my %hash=();
	
	my @statusA=split(/\n/, $statusS);
	
	if (!defined($type)){
		$type="status"
	}
	
	if (! $statusA[0] =~ /^Selected interface/){
		warn("Unexpected return from 'wpa_cli ".$type."': ".$statusA[0]);
		return undef;
	}
	
	my @interfaceA=split(/\'/, $statusA[0]);
	
	$hash{interface}=$interfaceA[1];
	
	my $statusAint=1;
	while(defined($statusA[$statusAint])){
		chomp($statusA[$statusAint]);
		my @linesplit=split(/=/, $statusA[$statusAint]);
		$hash{$linesplit[0]}=$linesplit[1];
		
		$statusAint++;
	}
	
	return %hash;
}

=head1 NOTES

This makes use of wpa_cli in a non-interactive form. This means that
interface and otp are not usable.

Better documentation and etc shall be coming shortly. Publishing this and starting work
on something that uses it in it's current form.

=head1 AUTHOR

Zane C. Bowers-Hadley, C<< <vvelox at vvelox.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-wireless-802_11--wpa-cli at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Wireless-802_11-WPA-CLI>.  I will be
notified, and then you'll automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::Wireless::802_11::WPA::CLI


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Wireless-802_11-WPA-CLI>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Wireless-802_11-WPA-CLI>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-Wireless-802_11-WPA-CLI>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-Wireless-802_11-WPA-CLI>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2011 Zane C. Bowers-Hadley, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Net::Wireless::802_11::WPA::CLI
