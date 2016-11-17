This provides a simple sample NodeJs application
that makes use of the Husky library that 
Node.Js apps can use to setup Git to setup a 
hook to run JSHint library that validates JavaScript code.


## Prepare

0. cd to a folder to hold the folder to hold the folder
   created when git clone is run:

   git_hook_node_jshint

0. Open a Terminal shell window and cd to the folder, then run:

   ```
   npm install
   ```
   
   This creates an **npm_modules** folder and populates
   it with dependencies from the internet.

   <pre>
> husky@0.7.0 install /Users/mac/gits/wilsonmar/devops/node-sample1/node_modules/husky
> node ./bin/install.js
&nbsp;
husky
  setting up hooks in .git/hooks/
  done
&nbsp;
Prehooks@1.0.0 /Users/mac/gits/wilsonmar/devops/node-sample1
├── husky@0.7.0
└─┬ jshint@2.9.4
  ├─┬ cli@1.0.1
  │ └─┬ glob@7.1.1
  │   ├── fs.realpath@1.0.0
  │   ├─┬ inflight@1.0.6
  │   │ └── wrappy@1.0.2
  │   ├── inherits@2.0.3
  │   ├── once@1.4.0
  │   └── path-is-absolute@1.0.1
  ├─┬ console-browserify@1.1.0
  │ └── date-now@0.1.4
  ├── exit@0.1.2
  ├─┬ htmlparser2@3.8.3
  │ ├── domelementtype@1.3.0
  │ ├── domhandler@2.3.0
  │ ├─┬ domutils@1.5.1
  │ │ └─┬ dom-serializer@0.1.0
  │ │   ├── domelementtype@1.1.3
  │ │   └── entities@1.1.1
  │ ├── entities@1.0.0
  │ └─┬ readable-stream@1.1.14
  │   ├── core-util-is@1.0.2
  │   ├── isarray@0.0.1
  │   └── string_decoder@0.10.31
  ├── lodash@3.7.0
  ├─┬ minimatch@3.0.3
  │ └─┬ brace-expansion@1.1.6
  │   ├── balanced-match@0.4.2
  │   └── concat-map@0.0.1
  ├── shelljs@0.3.0
  └── strip-json-comments@1.0.4
&nbsp;
npm WARN Prehooks@1.0.0 No repository field.
   </pre>

   The **.gitignore** file defined for the project
   specifies that the folder is not uploaded back to GitHub.
   This is also the case for the npm-debug.log created in case there is an error.


## Run the app

Invoke the Node.Js app

   ```
   node index.js
   ```

   The expected response is a new Terminal line.


## Git hooks   

The package.json file defines what Node does before Git actions.

### precommit

If this is in the package.json file:

   ```
  "scripts": {
    "precommit": "jshint index.js"
  },
   ```

jshint is invoked on index.js on `git commit` based on settings in file **.jshintrc**.
The file in the repo, these errors to appear based on the index.js in the repo:

   <pre>
index.js: line 3, col 15, Expected '===' and instead saw '=='.
index.js: line 4, col 40, Missing semicolon.
index.js: line 8, col 9, Expected '{' and instead saw 'doSomething'.
index.js: line 8, col 22, Missing semicolon.
index.js: line 11, col 35, Missing semicolon.
index.js: line 14, col 2, Missing semicolon.
index.js: line 3, col 9, 'num' is not defined.
index.js: line 7, col 12, 'num' is not defined.
&nbsp;
8 errors
&nbsp;
husky - pre-commit hook failed (add --no-verify to bypass)
   </pre>


Options specified are according to 
<a target="_blank" href="http://jshint.com/docs/options/">
http://jshint.com/docs/options</a>



### override

To commit without performing verification, use this command:

   ```
   git commit -m"update index.js" --no-verify  
   ```

### Fix

   PROTIP: After you insert lines, save the file 
   and get new line numbers in the error messages by running again.


### prepush

If this is in the package.json file:

   ```
"scripts": {
    "prepush": "jshint index.js"
  },
   ```

jshint is invoked on index.js on `git push`.

To push without performing verification,
change the package.json file to:

   ```
   git push --no-verify  
   ```

## Video

A video of this is at
<a target="_blank" href="https://www.youtube.com/watch?v=sTnatBgmYsE">
https://www.youtube.com/watch?v=sTnatBgmYsE</a>
and blog<br />
http://www.penta-code.com/prevent-bad-git-commits-and-pushes-with-husky/
