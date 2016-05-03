This article describes git utilities to use the git source code version control systems that store and delivery primarily text-based files.

I don't think I really understood the internals of git until I had to move folders from one project to another (and keep history).

Git is all about keeping the history of changes.

   NOTE: When a repo is cloned, a .git file contains the history of changes.

   PROTIP: When a repo is downloaded, the zip file does not contain a git folder, and thus no history.

## git_move_setup.sh
This populates in Github two repos SampleA and SamplB with folders,
so we can test the work on a temporary basis,
Each repo is populated with files containing a time stamp.
Thus, a history of changes is also populated within each repo.


There are two basic methods that address folders and log history differently:

1) git_move_history.sh - extracts out history log file and imports it into the destination repo after 
   the folders and files are moved without history to the destination folder.

   This is based on https://gist.github.com/voltagex/3888364 mentioned in
   http://blog.neutrino.es/2012/git-copy-a-file-or-directory-from-another-repository-preserving-history/
   which only works for individual files.

2) git_move_filter.sh - filter out both the folder and its history log. 

3) git_move.sh - This is not used. It's based on the git_move.sh from 
   https://gist.github.com/gregferrell/942639, which does not preserve history.


## git_move_filter.sh

### Get "directory 1" within repository A ready to move

   PROTIP: When a repo is downloaded, the zip file does not contain a git folder, and thus no history.

0. Clone the originating repo you want to split to your local machine,
   specifying the branch:

   ```
git clone --branch <branch> --origin origin --progress -v <git repository A url>
eg. git clone --branch master --origin origin --progress -v https://username@giturl/scm/projects/myprojects.git
   ```

   NOTE: The master branch should always be production ready, meaning it can be shipped with zero issues. So use another branch for experiments.
   
   PROTIP: Avoid monster repos. Divide the different concerns for a development project in several projects. For example, client code in one project and server code in another project.
   
   PROTIP: When a repo is cloned, the hidden .git folder contains all the history for that repo.

0. PROTIP: Make a zip right after cloning so you have a fall back no matter what happens.
   In Mac Finder, right-click on the folder and select Compress.

0. Rename the zip file to include the branch name.

   PROTIP: When a repo is downloaded rather than cloned,
   the branch name is added to the project name.

0. cd into the repo.
0. See where the local repo is hosted (remotely):

   ```
git remote -v
   ```

   NOTE: 'origin' is the default name.
   Additional remotes are sometimes defined for the github of different collaborators with different variations of the same subject.

0. Avoid accidentally pushing any remote changes by deleting the link to the upstream repository in github.

   ```
git remote rm origin
   ```

   `git remove -v` again will now return nothing.

0. Copy a folder name you want to move to your invisible clipboard
   (directory 1).

   NOTE: If you have multiple directories to move, repeat the steps below for each.


0. Filter out all files except the one you want and at the same time "promote"
   files in the directory up to the project root level.

   ```
git filter-branch --prune-empty --subdirectory-filter <directory 1> -- --all
   ```

   The `--prune-empty` with `git filter-branch` brings over commits from **ONLY** the other repo which involves the directory being moved.

   The official doc at https://git-scm.com/docs/git-filter-branch
   describes git filter-branch as rewrite revision history what is specifically mentioned after `--subdirectory-filter`.

   The `–-` (two dashes) separates paths from revisions.

   An example of the response (where "directory 1" is replaced with your folder name):

   ```
Rewrite 4667ec42e25fd23b634cd2ffb151ec26a886fa78 (6/6)
Ref 'refs/heads/<directory 1>' was rewritten
   ```

   CAUTION: If more directories are listed, something wrong happened
   and you would need to start over.

0. List to see files moved up, and other directories gone:

   ```
   ls
   ```

0. Clean-up:

   ```
git reset --hard
   ```

   An examaple of the response:

   ```
   HEAD is now at 90018a2 Update to Nuget packages
   ```

0. Clean-up:

   ```
git gc --aggressive
   ```

   An example of the response (which may take a while):

   ```
Counting objects: 664, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (644/644), done.
Writing objects: 100% (664/664), done.
Total 664 (delta 388), reused 250 (delta 0)
   ```

0. Prune:

   ```
git prune
   ```

0. Copy "directory 1" to you machine's clipboard again.
0. Move contents of root back into a "directory 1":

   ```
mkdir -p <directory 1>
git mv * <directory 1>
   ```

   The -p (parent) option creates intermediate directories if they do not already exist.
   See http://www.linfo.org/mkdir.html

0. Add and commit:

   ```
git add .
git commit -m"filter <directory 1>"
   ```

   The response is a list of rename operations.

   NOTE: Each commit can relate to several files within a entire repo.

0. Navigate to the folder.
0. Clone the destination repo "B" you want to end up with to your local machine.

0. cd <git repository B directory>

0. Establish a new remote connection called "repo-A-branch" 
   with the full local folder path to <directory 1>.

   ```
   git remote add repo-A-branch /User/me/<dir>/<project A>/<directory 1>
   ```

0. Verify that there are now two remotes listed:

   ```
   remote -v
   ```

   There should be (fetch) and (push) for origin and for "repo-A-branch".

0. Pull from this branch (containing only the directory you want to move) into repository B.

   ```
git pull repo-A-branch master
   ```

The pull copies both files and history. Note: You can use a merge instead of a pull, but pull works better.

0. Clean up the extra remote recreated:

   ```
git remote rm repo-A-branch
   ```

0. Make it happen on Github:

   ```
   git push
   ```

0. In Github, navigate to the project and view the history.

0. In the original project, remove the folders that were moved.


<a name="Resources">
## Resources</a>

This article was written based on input and inspiration from these resources (my thanks):

* https://help.github.com/articles/splitting-a-subfolder-out-into-a-new-repository/
git filter-branch 

* http://stackoverflow.com/questions/1365541/how-to-move-files-from-one-git-repo-to-another-not-a-clone-preserving-history poster mcarans presents a 3-stage approach with excellent notes.

* http://gbayer.com/development/moving-files-from-one-git-repository-to-another-preserving-history/ even though it's at the top of Google search results,
doesn't really work because it lacks the --prune-empty option.


wilsonmar - 
