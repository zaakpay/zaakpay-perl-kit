#!C:/xampp/perl/bin/perl.exe
use Apache2::Log ();
my $s = Apache2::ServerUtil->server;
my $slog = $s->log;
print "Content-type:text/html\r\n\r\n";
local ($buffer, @pairs, $pair, $name, $value, %FORM );
	$all='';
	my $bool=0;
	$secret = 'Your Secret Key goes here';
   	my @post_variables;
	my @post_values;
    $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
    if ($ENV{'REQUEST_METHOD'} eq "POST")
    {
        read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    }else {
		$buffer = $ENV{'QUERY_STRING'};
    }
    # Split information into name/value pairs
    @pairs = split(/&/, $buffer);
    foreach $pair (@pairs)
    {
		my $name, $value;
		($name, $value) = split(/=/, $pair);
		$value =~ tr/+/ /;
		$value =~ s/%(..)/pack("C", hex($1))/eg;
		my $paramName = $name;
		push @post_variables, $paramName;
		push @post_values, $value;
		$FORM{$name} = $value;
		if($name ne 'checksum') {
		$all .= "\'";
		if($name eq 'returnUrl')
		{
			$all .= removeLastSpace(sanitizedURL($value));
		}
		else
		{
			$all .= removeLastSpace(sanitizedParam($value));
		}
		$all .= "\'";
		}
	}
	
	push (@message,'Response:');
	push (@message,$all);

	push (@message,'Secret Key :');
	push (@message,$secret);
	$s->log_error(@message);
	
	sub removeLastSpace{
			my ($removeLastSpace) = @_;
			substr($removeLastSpace, length($removeLastSpace)-1) = '';
			return $removeLastSpace;
	}
	sub sanitizedParam {
			my ($sanitizedParam) = @_;
			$sanitizedParam =~ s/<|>|\(|\)|\{|\}|\?|\&|\*|~|`|!|#|$|%|\^|=|\+|\||\\|:|'|\"|;|,|\x5B|\x5D/ /g;
			return $sanitizedParam;
	}

	sub sanitizedURL {
			my ($sanitizedURL) = @_;
			$sanitizedURL =~ s/[^A-Za-z0-9|.|,]/ /g;
			return $sanitizedURL;
	}


	while (($key, $value) = each(%FORM))
	{
		if($key eq 'checksum'){
				$recd_checksum = $value;
		}
	}
	use Digest::SHA qw(hmac_sha256_hex);
	$digest=hmac_sha256_hex($all, $secret);
	$checksum=$digest;
	if($recd_checksum eq $checksum){
	$bool=1;
	}	else	{
	$bool=0;
	}
print '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN\" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
print '<html xmlns="http://www.w3.org/1999/xhtml">';
print '<head>';
print '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
print '<title>Zaakpay</title>';
print '</head>';
print '<body>';
print '<center>';
print '<table width="500px;">';
	while (($key, $value) = each(%FORM))
	{
			if ($bool == 0) 
			{
				if ($key eq "responseCode") 
				{
					print '<tr><td width="50%" align="center" valign="middle">'.$key.'</td><td width="50%" align="center" valign="middle"><font color=Red>***</font></td></tr>';
				}
				elsif ($key eq "responseDescription") 
				{
					print '<tr><td width="50%" align="center" valign="middle">'.$key.'</td><td width="50%" align="center" valign="middle"><font color=Red>This response is compromised.</font></td></tr>';
				}
				else 
				{
					print '<tr><td width="50%" align="center" valign="middle">'.$key.'</td><td width="50%" align="center" valign="middle">'.$value.'</td></tr>';
				}
			} 
			else 
			{
				print '<tr><td width="50%" align="center" valign="middle">'.$key.'</td><td width="50%" align="center" valign="middle">'.$value.'</td></tr>';
			}
	}
		print '<tr><td width="50%" align="center" valign="middle">Checksum Verified?</td>';
		if($bool == 1) 
		{
			print '<td width="50%" align="center" valign="middle">Yes</td></tr>';
		}
		else 
		{
			print '<td width="50%" align="center" valign="middle"><font color=Red>No</font></td></tr>';
		}

print '</table>';
print '</center>';
print '</body>';
print '</html>';
