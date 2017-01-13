This GitHub repository contains files used by and explained in Wilson Mar's
Git and GitHub course.

There are two editions of scripts in this repo.

File names ending in <strong>.ps1</strong> are PowerShell scripts that run on Windows,
but now also Mac and Linux machines after installing Microsoft's PowerShell.

File names ending in <strong>.sh</strong> are Bash scripts that normally run on Mac,
and now also on Anniversary Edition Windows 10 machines.
Such scripts are being phased out in favor of a PowerShell script for use by all.

Learners make use of two sets of scripts that issue <strong>git commands</strong>
so you can experiment to see what happens when you make a change to commands.

<hr />

<strong>git-hooks-install.ps1</strong> should be run after cloning locally
to install scripts that Git invokes automatically based on events.
A git clone is necessary to re-build the database.

<strong>git-sisters-update.ps1</strong> is a PowerShell script that
clones a sample sample repository you forked on GitHub.
It calls a script that sets git configurations for a project (or globally)<br />
<strong>git_client-config.ps1</strong>

<strong>git-sample-repo-create.ps1</strong> is a PowerShell script that
creates a repository on your local clones your fork of a sample sample repository.

All these scripts create a folder, but that folder is deleted at the beginning of each run
to make them "idempotent" in that each run of the script ends up in the same condition,
whether run the first time or subsequent times.

The scripts contain an <strong>exit</strong> after each set of steps
so you can examine the impact of the whole sequence of commands.

Additionally, diagrams (animated step-by-step in PowerPoint) have been prepared to illustrate the flow and sequence of commands.

Enjoy!
