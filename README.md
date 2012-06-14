# bisectr

The bisectr package is used to find commits that introduce bugs in a project's git history.
The first bad commit is one that introduces a bug; the commits before the first bad commit are good, and the commits after it are bad.

Sometimes you can't test a commit because it's broken and you can't load the package at that commit.
In these cases, you don't know if this commit is good or bad, relative to the bug you're looking for.
Instead of marking these commits good or bad, they can be marked **skip**.

*****

# Usage

The bisectr package is to be used with R scripts that are called from the command line -- not from inside R, but the regular command shell.

## Running a test script

The scripts can be run from the command line.
They should be saved in the top level of your project directory, like `ggplot2/mytestscript.r` and made executable with `chmod 755 mytestscript.r`

```
# Go to the top level dir of your project
cd ggplot2
chmod 755 mytestscript.r

git bisect reset
git bisect start
```

First, check if the script works properly, and find the good and bad commits.
This will check out the `master` branch and run the test script.
It won't actually mark commits good or bad, but it will report whether the test result is **good**, **bad**, or **skip**.
This should be a bad commit.

```
git checkout master
./mytestscript.r

# If this is indeed bad, you can mark the commit bad with:
git bisect bad
```

Then you need to find an older commit that is good
In this case, we'll check out an older version of ggplot2, a commit that was tagged `ggplot2-0.9.0`.
(You can use any valid git commit ref, like a SHA hash, or branch name.)

```
git checkout ggplot2-0.9.0
./mytestcript.r

# If this is indeed good, you can mark it good with:
git bisect good
```

Now that you've marked a bad and good commit, you can run the automated test, which will do a binary search on commits until it finds the guilty commit.
At the end, this will report the first bad commit.

```
git bisect run ./mytestscript.r
```


## Template scripts

These template scripts should be saved in the top level of your project directory.
For example, if the project is ggplot2, a scripts should be saved in `ggplot2/mytestscript.r`.

### Fully automated tests

Here is a template script for a fully automated test.
In this template replace the (trivial) test (`x==2`) with your test code.
It has three possible return values.

* If the test is successful, mark the commit as **good**.
* If the test is unsuccessful, mark the commit as **bad**.
* If the test throws an error, mark the commit as **skip**.

```R
#!/usr/bin/Rscript

# To run this script:
# git bisect reset
# git bisect start <bad_commit> <good_commit>
# git bisect run mytestscript.r

cat("\n===== Running test script ======\n")
library(bisectr)

# This is the test function. It is defined here and run later.
# A fully automated test
testfun <- function() {

  # ... Put your test code here ...
  x <- 1 + 1

  # If some condition is met, return good; otherwise bad
  if (x == 2)
    return("good")
  else
    return("bad")
}

# If load error, mark "skip"
bisect_load_all(".", on_error = "skip")

# Run the test, and if error, mark skip
bisect_runtest(testfun, on_error = "skip")
```

You can change the return codes for your purposes. For example, this may be what you want:

* If the test code runs without throwing an error, mark the commit as **good**.
* If the test code throws an error, marks the commit as **bad**.


```R
#!/usr/bin/Rscript

# To run this script:
# git bisect reset
# git bisect start <bad_commit> <good_commit>
# git bisect run mytestscript.r

cat("\n===== Running test script ======\n")
library(bisectr)

# This is the test function. It is defined here and run later.
# A fully automated test
testfun <- function() {

  # ... Put your test code here ...

  # If we made it this far, that means we didn't throw an error, so return good
  return("good")
}

# If load error, mark "skip"
bisect_load_all(".", on_error = "skip")

# Run the test, and if error, mark bad
bisect_runtest(testfun, on_error = "bad")
```

### Interactive tests

Sometimes it's difficult or impossible to fully automate a test.
This is often true if the test involves graphical output -- you need to visually inspect the output to see if it looks right.
You can interactively get return codes with the `bisect_return_interactive()` function.
This will allow you to view the output and then type in g/b/s, to mark it good/bad/skip.

This template will run a test that does the following.
It will try to make a plot, but inspecting the plot will require you to visually inspect and decide whether it's good or bad.
Here are the desired criteria:

* If the test looks right, mark the commit as **good**. (requires interaction)
* If the test looks wrong, mark the commit as **bad**. (requires interaction)
* If the test throws an error, mark the commit as **skip**. (automatic)


```R
#!/usr/bin/Rscript

# To run this script:
# git bisect reset
# git bisect start ggplot2-0.9.1 c5b872e
# git bisect run mytestscript.r

cat("\n===== Running test script ======\n")
library(bisectr)

# This is the test function. It is defined here and run later.
# A test that requires visual inspection and manual response
testRunInteractive <- function() {

  # ... Test code here ...
  dat <- data.frame(x=LETTERS[1:3], 
                    y=c(10,5,8,7,9,4),
                    g=c("a","a","a","b","b","b"))

  p <- ggplot(dat, aes(x=x, y=y, fill=g)) +
      geom_bar(position="dodge", fill="white", colour="black", stat="identity")
  # ... End test code ...

  # Need to manually open graphics window because we're in a script
  # Try different graphic devices, depending on platform
  # (Not sure about Windows)
  if      (capabilities()['aqua']) { quartz() }
  else if (capabilities()['X11'])  { x11() }

  # Must explicitly print ggplot object because we're in a script
  print(p)

  # On some platforms we need to wait a little bit to allow the plot to render
  Sys.sleep(0.75)

  # User must visually inspect and mark good/bad/skip
  bisect_return_interactive()
}

# If load error, mark SKIP
bisect_load_all(".", on_error = "skip")

# If error, mark SKIP
bisect_runtest(testRunInteractive, on_error = "skip")
```

*****

# Notes

## Installing packages instead of using `load_all`

Normally, you can use the `bisect_load_all()` function, which calls `devtoos::load_all()`.
However, sometimes `load_all()` doesn't work right, and you have to install the package to run the test.
In these cases, use `bisect_install()` and `bisect_require()` (note that installing a package takes more time than `load_all()`.)
.
This will install the package to a temporary directory, so there's no need to manually clean it up after testing.

```R
# Instead of bisect_load_all(".")
bisect_install(".", on_fail = "skip")
bisect_require(mypackage, on_fail = "skip")
```

By default, `bisect_install()` will mark the commit as **skip** on a failure to install, but you can change this.
For example, you can mark the commit as **bad** on failure to install:

```R
bisect_install(".", on_fail="bad")
```