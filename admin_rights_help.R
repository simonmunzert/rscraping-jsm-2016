
# To set the default directory for user installed packages for users who cannot open R as an administrator
#
# First assume the user's folder, where they have read/write rights is
# "C:\\users\usernames\desktop\R_library"

# Then have them type

.libPaths(c(.libPaths(),"C:\\users\\usernames\\desktop\\R_library"))

Sys.setenv(PATH=paste(Sys.getenv("PATH"),"C:\\MikTeX\\miktex\\bin\\x64",sep=";"))

## Also often helpful in an controlled environments
## Rconfigure_default.R
library(utils)
## Using Internet Explorer proxy settings is
setInternet2(TRUE)
