\name{bisect_source}
\alias{bisect_source}
\title{Like \code{source}, but for bisect tests.}
\usage{
  bisect_source(file, ..., on_error = "skip")
}
\arguments{
  \item{file}{The file to load}

  \item{...}{Other arguments to pass to
  \code{\link{source}}}

  \item{on_error}{What to do if loading throws an error
  (default is to mark this commit as "skip")}
}
\description{
  If the file fails to load, the default is mark this
  commit as skip.
}
\seealso{
  \code{\link{source}}

  \code{\link{bisect_load_all}}

  \code{\link{bisect_install}}

  \code{\link{bisect_runtest}}

  \code{\link{bisect_return_interactive}}
}

