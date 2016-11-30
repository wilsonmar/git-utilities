# README.md

This GitHub repository contains files referenced by Wilson Mar's
Git and GitHub course.

File names ending in <strong>.ps1</strong> are PowerShell scripts that run on Windows,
but now also Mac and Linux machines after installing Microsoft's PowerShell.

File names ending in <strong>.sh</strong> are Bash scripts that normally run on Mac,
and now also on Anniversary Edition Windows 10 machines.
Such scripts are being phased out in favor of a PowerShell script for use by all.

Learners make use of two sets of scripts that issue <strong>git commands</strong>
so you can experiment to see what happens when you make a change to commands.

<strong>git-sisters-update.ps1</strong> is a PowerShell script that
clones a sample sample repository you forked on GitHub.
It calls a script that sets git configurations for a project (or globally)<br />
<strong>git_client-config.ps1</strong>

<strong>git-sample-repo-create.ps1</strong> is a PowerShell script that
creates a repository on your local clones your fork of a sample sample repository.

All these scripts create a folder, but that folder is deleted at the beginning of each run.

Enjoy!