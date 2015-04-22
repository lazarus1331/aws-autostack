AWS stack creation tool
=======================
This tool will help with the creation of AWS Cloudformation stacks by automatically validating the template and the stack names prior to creation. It will also monitor the creation of the stack and report on the completion status, and will also print the outputs of the stack. This removes the tedium of having to manually run describe-stacks in order to determine when the stack is finished being stood up.

Requirements
============
In order to work with the AWS API, certain software requirements must be met in order for autostack to work, these are:
- AWS CLI (python)
- perl 5.010

Perl Modules:
- JSON

Usage
=====
Autostack requires a cloudformation template, and a unique stack name.

    autostack.pl --file /path/to/file --name mystack

