\name{bisect_runtest}
\alias{bisect_runtest}
\title{Run a test function for git bisect testing.}
\usage{
  bisect_runtest(fun, on_error = "skip",
    msg = "Running test...")
}
\arguments{
  \item{fun}{The test function}

  \item{on_error}{What to do if running \code{fun} throws
  an error (default is to mark this commit as skip)}

  \item{msg}{A message to print to the console when running
  the test}
}
\description{
  If the function \code{fun} returns \code{"good"} or
  \code{TRUE}, quit and return a code to mark this commit
  as good. If the function returns \code{"bad"} or
  \code{FALSE}, quit and return a code to mark this commit
  as bad. If the function returns \code{"skip"} or
  \code{NA}, quit and return a code to mark this commit as
  skip. If the function returns \code{"ignore"} or
  \code{NULL}, do nothing.
}
\details{
  It is also important to set \code{on_error}. This tells
  it what to do when the test function throws an error. The
  default behavior is to mark this commit as skip. However,
  in some cases, it makes sense to mark this commit as bad
  if an error is thrown.
}
\seealso{
  \code{\link{bisect_load_all}}

  \code{\link{bisect_install}}

  \code{\link{bisect_source}}

  \code{\link{bisect_return_interactive}}
}

