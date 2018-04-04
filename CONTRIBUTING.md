# How to contribute

:+1::tada: First of all, thank you for taking the time to read this.:tada::+1:

We need volunteer developers to help this project come to fruition.

> **Note:** [Please don't file an issue to ask a question.](https://blog.atom.io/2016/04/19/managing-the-deluge-of-atom-issues.html) You'll get faster results by using the resources below.

## GitHub LFS (Large File Storage)

Please don't add binary files among text files. Pushing large files to forks of a repository count against the parent repository's bandwidth and storage quotas, rather than the quotas of the fork owner.

Push Git LFS objects to public forks if the repository network already has Git LFS objects or you have write access to the root of the repository network.

https://help.github.com/articles/duplicating-a-repository/#mirroring-a-repository-that-contains-git-large-file-storage-objects


## Social channels

If you haven't already, come find us in IRC ([#opengovernment](irc://chat.freenode.net/opengovernment) on freenode). We want you working on things you're excited about.

Here are some important resources:

  * [OpenGovernment for Developers](http://opengovernment.org/pages/developer) tells you where we are,
  * [Our roadmap](http://opengovernment.org/pages/wish-list) is the 10k foot view of where we're going, and
  * [Pivotal Tracker](http://pivotaltracker.com/projects/64842) is our day-to-day project management space.
  * Mailing list: Join our [developer list](http://groups.google.com/group/opengovernment/)
  * Bugs? [Lighthouse](https://participatorypolitics.lighthouseapp.com/projects/47665-opengovernment/overview) is where to report them
  * IRC: chat.freenode.net channel [#opengovernment](irc://chat.freenode.net/opengovernment). We're usually there during business hours.

## Testing

We have a handful of Cucumber features, but most of our testbed consists of RSpec examples. Please write RSpec examples for new code you create.

## Submitting changes

Please send a [GitHub Pull Request to opengovernment](https://github.com/opengovernment/opengovernment/pull/new/master) with a clear list of what you've done (read more about [pull requests](http://help.github.com/pull-requests/)). When you send a pull request, we will love you forever if you include RSpec examples. We can always use more test coverage. Please follow our coding conventions (below) and make sure all of your commits are atomic (one feature per commit).

Always write a clear log message for your commits. One-line messages are fine for small changes, but bigger changes should look like this:

    $ git commit -m "A brief summary of the commit
    > 
    > A paragraph describing what changed and its impact."

## Coding conventions

Start reading our code and you'll get the hang of it. We optimize for readability:

  * We indent Bash shell files using three spaces (soft tabs)
  * We use HAML for all views
  * We avoid logic in views, putting HTML generators into helpers
  * We ALWAYS put spaces after list items and method parameters (`[1, 2, 3]`, not `[1,2,3]`), around operators (`x += 1`, not `x+=1`), and around hash arrows.
  
Remember, this is open source software. Consider the people who will read your code, and make it look nice for them. It's sort of like driving a car: Perhaps you love doing donuts when you're alone, but with passengers the goal is to make the ride as smooth as possible.

  * So that we can consistently serve images from the CDN, always use image_path or image_tag when referring to images. Never prepend "/images/" when using image_path or image_tag.
  * Also for the CDN, always use cwd-relative paths rather than root-relative paths in image URLs in any CSS. So instead of url('/images/blah.gif'), use url('../images/blah.gif').

Thanks!

This is based on other CONTRIBUTING files:
* https://github.com/atom/atom/blob/master/CONTRIBUTING.md
* https://github.com/rails/rails/blob/master/CONTRIBUTING.md
* https://github.com/opengovernment/opengovernment/blob/master/CONTRIBUTING.md
