
#!C:/xampp/perl/bin/perl.exe
use IO::File;
use Apache2::Log ();
my $s = Apache2::ServerUtil->server;
my $slog = $s->log;


print "Content-type:text/html\r\n\r\n";
	local ($buffer, @pairs, $pair, $name, $value, %FORM );
	$all='';
	$secret = 'Your Secret Key goes here';
    # Read in text
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
		$value =~ tr//+ /;
		$value =~ s/%(..)/pack("C", hex($1))/eg;
		my $paramName = $name;
		push @post_variables, $paramName;
		push @post_values, $value;
		$all .= "\'";
		if($name eq 'returnUrl')
		{
		
			$all .= sanitizedURL($value);
			$FORM{$name} = sanitizedURL($value);
		}
		else
		{
			$all .= sanitizedParam($value);
			$FORM{$name} = sanitizedParam($value);
		}
		$all .= "\'";
		
    }

	push (@message,'\n AllParams:');
	push (@message,$all);

	push (@message,'\n Secret Key :');
	push (@message,$secret);
	$s->log_error(@message);

	sub sanitizedParam {
			my ($sanitizedParam) = @_;
			$sanitizedParam =~ s/<|>|\(|\)|\{|\}|\?|\&|\*|~|`|!|#|$|%|\^|=|\+|\||\\|:|'|\"|;|,|\x5B|\x5D//g;
			return $sanitizedParam;
	}

	sub sanitizedURL {
			my ($sanitizedURL) = @_;
			$sanitizedURL =~ s/[^A-Za-z0-9]//g;
			return $sanitizedURL;
	}
	
#checksum caluculation
	use Digest::SHA qw(hmac_sha256_hex);
	$digest=hmac_sha256_hex($all, $secret);
	$checksum=$digest;


print "<html>";
print "<head>";
print "<script type='text/javascript'>";
print "function submitForm()\{";
print "			var form = document.forms[0];";
print "			form.submit();";
print "		\}";
print "</script>";

print "<title>Redirecting please wait</title>";
print "</head>";
print "<body onload='javascript:submitForm()'>";
print "<center>";
print "<table width=\"500px;\">";
print "	<tr>";
print "		<td align=\"center\" valign=\"middle\">Do Not Refresh or Press Back <br/> Redirecting to Zaakpay</td>";
print "	</tr>";
print "	<tr>";
print "	<td align=\"center\" valign=\"middle\">";


print "<form action='https://api.zaakpay.com/transact' method='post'>";

for($i=0;$i<scalar(@post_variables);$i++) {
if ($key eq 'returnUrl') {
				print '<input type="hidden" name="'.$post_variables[$i].'" value="'.sanitizedURL($post_values[$i]).'" />'."\n";
		} else {
				print '<input type="hidden" name="'.$post_variables[$i].'" value="'.sanitizedParam($post_values[$i]).'" />'."\n";
		}
		}
		print '<input type="hidden" name="checksum" value="'.$checksum.'" />'."\n";
print "</form>";
print"		</td>";

print "	</tr>";

print "</table>";

print "</center>";
print "</body>";
print "</html>";
1;
