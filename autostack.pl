#!/usr/bin/perl
# create aws stacks using cloudformation templates, and verify completion
use 5.010;
use strict;
use warnings;

use Carp;
use Data::Dumper;
use Getopt::Long;
use JSON;
#use LWP::UserAgent;

my %options;
GetOptions(
    \%options,
    "name|n:s",
    "file|f:s",
    "help|h:+",
);

## Init ##
die usage("Here is some help.") if $options{help};
die usage("Template file does not exist.") unless ( defined($options{file}) && -e $options{file} );
die usage("Stack name must be provided.") unless ( defined($options{name}) );

## Main ##
$options{file} =~ s|/|//|;  # normalize file name for aws

# 1. Validate template & ensure aws-cli libraries are installed
validate_template($options{file});

# 2. Validate unique name
validate_name($options{name});

# 3. Create the stack
create_stack(%options);

# 4. Wait for stack creation to complete
print "... waiting for stack creation to complete. Please be patient.\n"

# 5. Validate stack created successfully

# 6. Test webpage

print "END\n";
exit(0);
## END ##
sub create_stack {
    my @opts = @_;
    my $cmd = "aws cloudformation create-stack --stack-name $opts{name} --template-body file://$opts{file} 2>&1";
    my $results;
    eval { $results = qx($cmd) };
    if ($? >> 8 == 0 && defined($results)) {
        print "OK: stack creation started successfully.\n";
        my $id_ref = JSON->new->utf8->decode($results);
        print "\tStackId: $id_ref->{StackId}\n";
    } else {
        die "FAIL: Cloudformation stack creation failed:$results\n";
    }
    return
}

sub validate_name {
    my $name = shift;
    #open(my $FH, "<", "/home/michael/GIT/aws-autostack/test/describe-stacks.json");
    #local $/;
    #my $desc_json = <$FH>;
    my $desc_json = qx(aws cloudformation describe-stacks);
    my $stack_ref = JSON->new->utf8->decode($desc_json);
    my @stacks = @{$stack_ref->{Stacks}};
    foreach (@stacks) {
        next unless defined($_->{StackName});
        if ( $_->{StackName} =~ m/$name/i ) {
            die "FAIL: The stack name $name is already in use, please use another unique name.";
        }
    }
    print "OK: Stack name unique.\n";
    return
}

sub validate_template {
    my $file = shift;
    my $filetest;
    my $cmd = "aws cloudformation validate-template --template-body file://$file 2>&1";
    my $cli_test = qx(aws cloudformation help);
    if ( !defined($cli_test) ) {
        die "failed to execute aws command. Please install the aws-cli library: pip install awscli (Requires Python 2.6.5 or higher.)\n$!";
    }
    eval { $filetest = qx($cmd) };
    if ($? >> 8 == 0 && defined($filetest)) {
        print "OK: template validation successful.\n";
    } else {
        die "FAIL: Cloudformation template validation failed:$filetest\n";
    }
    return
}

sub usage {
    my $txt = shift;
    print "\n".$txt."\n";
    print <<USAGE;

    Usage: $0 --file|-f {path/to/cftemplate} --name|-n {stack name}

            file: the cloudformation template file
            name: the unique name to assign the stack
    
USAGE
    exit();
}

