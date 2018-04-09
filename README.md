---
layout: post
title: "Install, configure, and test all on a MacOS laptop"
excerpt: "Everything you need to be a professional developer"
tags: [API, devops, evaluation]
Categories: Devops
filename: README.md
image:
  feature: https://cloud.githubusercontent.com/assets/300046/14612210/373cb4e2-0553-11e6-8a1a-4b5e1dabe181.jpg
  credit: And Beyond
  creditlink: http://www.andbeyond.com/chile/places-to-go/easter-island.htm
comments: true
---
<i>{{ page.excerpt }}</i>

This article explains the script that builds a Mac machine with "everything" needed by a professional developer.

This is a <strong>"bootstrapping"</strong> script to enable you to more easily manage the complexity of competing stacks of components and their different versions. Java, Python, Node and their most popular add-ons are covered here.

<pre><strong>sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/git-utilities/master/mac-install-all.sh)"
</strong></pre>

Logic in the script goes beyond what Homebrew does, and <strong>configures</strong> the component just installed:

   * Install dependent components where necessary
   * Display the version number installed (to a log)
   * Add alias and paths in <strong>.bash_profile</strong> (if needed)
   * Perform configuration (such as adding a missing file needed for mariadb to start)
   * Edit configuration settings (such as changing default port within Nginx within config.conf file)
   * Upgrade and uninstall if that is available
   * Run a demo using the component to ensure that what has been installed actually works. 

## TD;LR Customization

This bring DevSecOps-style <strong>"immutable architecture"</strong> to MacOS laptops. Immutability means replacing the whole machine instance instead of upgrading or repairing faulty components.

Target users of this script are those who configure new laptops for developers joining the organization,
so each developer doesn't waste days installing everything one at a time (and doing it differently than colleagues). 

To do the above manually for each component would involve hours needlessly, and be error-prone.

Technical techniques for the Bash shell scripting are described separtely at [Bash scripting page in this website](/bash-coding/).

<hr />   

1. Edit file <strong>secrets.sh</strong> in the repo to customize what you install. 

   PROTIP: The default specification in the file is for a bare bones minimal components.
   Edit the file to add more tools to install.

   On a 4mbs network the run takes less than 5 minutes for a minimal install.

   PROTIP: A faster network or a proxy nexus server providing installers within the firewall would speed things up a lot and ensure that vetted installers are used.

2. In the string for each category, add the keyword for each app you want to install.
   
   There are several category variables: GIT_TOOLS, etc. 

3. Edit the script and search for components in "other" for each category.
4. In the list of brew, pip, or npm commands, if you see a component you want to install,
   remove the "#" character which treats the line as a comment.
5. In the secrets.sh, add "other" for the category (MAC_TOOLS, PYTHON_TOOLS, NODE_TOOLS, etc.) so the script will invoke the other list.

   ## Update All Arguement 

6. Upgrade to the latest versions of ALL components when "update" is added to the calling script:

   <pre><strong>chmod +x mac-install-all.sh
   mac-install-all.sh update
   </string></pre>

   CAUTION: This often breaks things because some apps are not ready to use a newer dependency.

   NOTE: This script does NOT automatically uninstall modules.
   But if you're brave enough, invoke the script this way to remove components so you recover some disk space:

   <pre><strong>
   mac-install-all.sh uninstall
   </string></pre>

   This is not an option for components that add lines to ~/.bash_profile.
   It's quite dangerous because the script cannot differentiate whether customizations occured to what it installed.

## Mac apps

Apps on Apple's App Store for Mac need to be installed manually. Popular apps include:

   * Office for Mac 2016
   * BitDefender for OSX
   * CrashPlan (for backups)
   * Amazon Music
   * RDP from Microsoft
   * etc.

The brew "mas" manages Apple Store apps, but it only manages apps that have already been paid for. But mas does not install apps new to your Apple Store account.

## Java tools via Maven, Ant

Apps added by specifying in JAVA_TOOLS are GUI apps.

Most other Java dependencies are specified by manually added in each custom app's <strong>pom.xml</strong> file
to specify what Maven downloads from the Maven Central online repository of installers at

   <a target="_blank" href="
   http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.dbunit%22">
   http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.dbunit%22</a>

Popular in the Maven Repository are:

   * <strong>yarn</strong> for code generation. JHipster uses it as an integrated tool in Java Spring development.
   * <strong>DbUnit</strong> extends the JUnit TestCase class to put databases into a known state between test runs. Written by Manuel Laflamme, DbUnit is added in the Maven pom.xml (or Ant) for download from Maven Central. See http://dbunit.wikidot.com/
   * <strong>mockito</strong> enables calls to be mocked as if they have been creted.
   Insert file java-mockito-maven.xml as a dependency to maven pom.xml
   See https://www.youtube.com/watch?v=GKUlQMrbtHE - May 28, 2016
   and https://zeroturnaround.com/rebellabs/rebel-labs-report-go-away-bugs-keeping-your-code-safe-with-junit-testng-and-mockito/9/

   * <strong>TestNG</strong> 
   See http://testng.org/doc/download.html
   and https://docs.mendix.com/howto/testing/create-automated-tests-with-testng
   
   When using Gradle, insert file java-testng-gradle as a dependency to gradle working within Eclipse plug-in
   Build from source git://github.com/cbeust/testng.git using ./build-with-gradle
   
TODO: The Python edition of this will insert specs such as this in pom.xml files.   


## Logging

The script outputs logs to a file.

This is so that during runs, what appears on the command console are only what is relevant to debugging the current issue.

At the end of the script, the log is shown in an editor to <strong>enable search</strong> through the whole log.

## 

Other similar scripts (listed in "References" below) run

http://groovy-lang.org/install.html

## Cloud Sync

Dropbox, OneDrive, Google Drive, Amazon Drive


<a name="EclipsePlugins"></a>

## Eclips IDE plug-ins

http://download.eclipse.org/releases/juno

Within Eclipse IDE, get a list of plugins at Help -> Install New Software -> Select a repo -> select a plugin -> go to More -> General Information -> Identifier

   <pre>eclipse -application org.eclipse.equinox.p2.director \
-destination d:/eclipse/ \
-profile SDKProfile  \
-clean -purgeHistory  \
-noSplash \
-repository http://download.eclipse.org/releases/juno/ \
-installIU org.eclipse.cdt.feature.group, \
   org.eclipse.egit.feature.group
   </pre>

   "Equinox" is the runtime environment of Eclipse, which is the <a target="_blank" href="http://www.vogella.de/articles/OSGi/article.html">reference implementation of OSGI</a>.
   Thus, Eclipse plugins are architectually the same as bundles in OSGI.

   Notice that there are different versions of Eclipse repositories, such as "juno".

   PROTIP: Although one can install several at once, do it one at a time to see if you can actually use each one.
   Some of them:

   <pre>
   org.eclipse.cdt.feature.group, \
   org.eclipse.egit.feature.group, \
   org.eclipse.cdt.sdk.feature.group, \
   org.eclipse.linuxtools.cdt.libhover.feature.group, \
   org.eclipse.wst.xml_ui.feature.feature.group, \
   org.eclipse.wst.web_ui.feature.feature.group, \
   org.eclipse.wst.jsdt.feature.feature.group, \
   org.eclipse.php.sdk.feature.group, \
   org.eclipse.rap.tooling.feature.group, \
   org.eclipse.linuxtools.cdt.libhover.devhelp.feature.feature.group, \
   org.eclipse.linuxtools.valgrind.feature.group, \
   </pre>

   <a target="_blank" href="https://stackoverflow.com/questions/2692048/what-are-the-differences-between-plug-ins-features-and-products-in-eclipse-rcp">NOTE</a>:
   A feature group is a list of plugins and other features which can be understood as a logical separate project unit
   for the updates manager and for the build process.

   ## Others like this

   * https://github.com/andrewconnell/osx-install described at http://www.andrewconnell.com/blog/rapid-complete-install-reinstall-os-x-like-a-champ-in-three-ish-hours separates coreinstall.sh from myinstall.sh for personal preferences.
