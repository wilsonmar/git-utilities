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

<a name="Extras"></a>

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

Like many, you may have an AirPort Time Capsule to back up everything using the MacOS Time Machine app.
However, as <a target="_blank" href="https://gist.github.com/zenorocha/7159780">this person discovered</a>, 

> "I don't want all the crap I had in the old one."

This script helps you manage what you have installed so you can, but don't have to start from scratch.

Target users of this script are those who configure new laptops for developers joining the organization,
so each developer doesn't waste days installing everything one at a time (and doing it differently than colleagues). 

To do the above manually for each component would involve hours needlessly, and be error-prone.

Technical techniques for the Bash shell scripting are described separtely at [Bash scripting page in this website](/bash-coding/).

## How this works

This script references a folder in your Home folder named <strong>git-utilities</strong>, 
It contains a configuration file named <strong>secrets.sh</strong> which you edit to specify what you want installed and run. The file's name is suffixed with ".sh" because it is run to establish variables for the script to reference. You don't run the file yourself. It is run by script <strong>mac-install-all.sh</strong> which you initiate within a Terminal command line.

1. The starting point (generic version) of these files are in a public GitHub repository:

   <a target="_blank" href="
   https://github.com/wilsonmar/git-utilities">
   https://github.com/wilsonmar/git-utilities</a>

   If you know what I'm talking about and have a GitHub account, you may Fork the repo under your own account and, while in a Teminal window at your Home folder, git clone it locally under your Home folder.
   This approach would enable you to save your changes back up to GitHub under your own account.

   Alternately, follow these steps to create an initial installation of what many developers use
   (but you won't be able to upload changes back to GitHub):

2. Triple-click this command and press command+C to copy to your invisible Clipboard:

   <pre><strong>sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/git-utilities/master/mac-install-all.sh)"
   </strong></pre>

2. Open a Terminal and press keys command+V to paste it from Clipboard.
3. Press Enter to run it.

   If your home folder does not contain a folder named "git-utilities",
   the script will create one by Git cloning, using a Git client it first installs if there isn't one already.

   A folder is necessary to hold additional folders such as "hooks" used by Git (if marked for install.)
   File "mac-bash-profile.txt" contains starter entries to insert in ~/.bash_profile that is executed before MacOS opens a Terminal session. 
   Ignore the other files.

4. Wait for the script to finish.

   On a 4mbs network the run takes less than 5 minutes for a minimal install.

   PROTIP: A faster network or a proxy nexus server providing installers within the firewall would speed things up a lot and ensure that vetted installers are used.

   When the script ends it pops up a log file in the TextEdit program that comes with MacOS.

5. Within TextEdit, review the log file.
6. Close the log file.
7. click File and navigate to your Home folder then within <tt>git-utilities</tt> to 
   open file <strong>secrets.sh</strong> in the repo so you can customize what you want installed. 

   <pre><strong>textedit secrets.sh
   </strong></pre>

   PROTIP: The default specification in the file is for a "bare bones" minimal set of components.
   If you run it again, it will not install it again.

   There is a key (variable name) for each category (MAC_TOOLS, etc.).

8. Among the comments (which begin with a pound sige) look for keywords for programs you want.
   
   Keywords shown are for the most popular programs. The mac-install-all.sh script contains logic go
   get it setup fully <a href="#Extras">(as summarized above)</a>.

   ### TRYOUT one at a time

8. Scroll to the bottom of the secrets.sh file and click between the double-quotes of <tt><strong>TRYOUT=""</strong></tt>.

   Paste or type the keyword of the components you want opened (invoked) by the script.

   We don't want to automatically open every component installed because that would be overwhelming.

   This way you have a choice.

9. Save the file. You need not exit the text editor completely if you want to re-run.
10. Run the script to carry out your changes:

    <pre><strong>chmod +x mac-install-all.sh
    mac-install-all.sh 
    </strong></pre>

    There are several variations possible:

    ### Update All Calling Arguement 

11. Upgrade to the latest versions of ALL components when "update" is added to the calling script:

    <pre><strong>chmod +x mac-install-all.sh
    mac-install-all.sh update
    </strong></pre>

    CAUTION: This often breaks things because some apps are not ready to use a newer dependency.

    NOTE: This script does NOT automatically uninstall modules.
    But if you're brave enough, invoke the script this way to remove components so you recover some disk space:

    <pre><strong>
    mac-install-all.sh uninstall
    </string></pre>

    This is not an option for components that add lines to ~/.bash_profile.
    It's quite dangerous because the script cannot differentiate whether customizations occured to what it installed.

    ### Edit mac-install.sh for others

    There are lists of additional programs (components) you may elect to install.

12. At the Terminal, use TextEdit or a other text editor to view the script file:

    <pre><strong>textedit mac-install.sh
    </strong></pre>

13. Press command+F to search for "others" (including the double-quotes).
 
    PROTIP: Several categories have a list of brew commands to install additional components.
    (MAC_TOOLS, PYTHON_TOOLS, NODE_TOOLS, etc.) 

14. For each additional component you want, delete the # to un-comment it.

    Remember that each component installed takes more disk space.


## Mac apps

Apps on Apple's App Store for Mac need to be installed manually. <a target="_blank" href="https://www.reddit.com/r/osx/comments/4hmgeh/list_of_os_x_tools_everyone_needs_to_know_about/">
Popular apps</a> include:

   * Office for Mac 2016
   * BitDefender for OSX
   * CrashPlan (for backups)
   * Amazon Music
   * <a target="_blank" href="https://wilsonmar.github.io/rdp/#microsoft-hockeyapp-remote-desktop-for-mac">HockeyApp RDP</a> (Remote Desktop Protocol client for controlling Microsoft Windows servers)
   * Colloquy IRC client (at https://github.com/colloquy/colloquy)
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

## Scape for Fonts in GitHub
 
Some developers have not put their stuff from GitHub into Homebrew. So we need to read (scrape) the website and see what is listed, then grab the text and URL to download.

Such is the situation with font files at 
https://github.com/adobe-fonts/source-code-pro/releases/tag/variable-fonts
The two files desired downloaded using the curl command are:

* https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Italic.ttf
* https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Roman.ttf

The files are downloaded into <a target="_blank" href="https://support.apple.com/en-us/HT201722">where MacOS holds fonts available to all users</a>: <tt>/Library/Fonts/</tt>

<a target="_blank" href="http://sourabhbajaj.com/mac-setup/iTerm/README.html">ITerm2 can make use of these font files</a>.

## Other lists of Mac programs 

   * https://github.com/paulirish/dotfiles/blob/master/brew-cask.sh
   (one of the earliest ones by a legend at Google)

   * https://github.com/andrewconnell/osx-install described at http://www.andrewconnell.com/blog/rapid-complete-install-reinstall-os-x-like-a-champ-in-three-ish-hours separates coreinstall.sh from myinstall.sh for personal preferences.

   * https://www.reddit.com/r/osx/comments/3u6mob/what_are_the_top_10_osx_applications_you_use/
   * https://github.com/siyelo/laptop
   * https://github.com/evanchiu/dotfiles
   * https://github.com/jeffreyjackson/mac-apps
   * https://github.com/jaywcjlove/awesome-mac/blob/master/README.md
   * https://medium.com/@ankushagarwal/maximize-developer-productivity-on-a-mac-a9ae6fbaedab
   * https://dotfiles.github.io/