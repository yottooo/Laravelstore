::nx::mongo::db connect -db "tutorial"

#
# Used for the register new user
#
namespace eval ::qa {
  set userName [ns_queryget username]

  if {[User find all -cond [list username = $userName] ] eq "" } {
    set p [User new \
         -username [ns_queryget username] \
         -email [ns_queryget email] \
         -password [ns_queryget password]]
    $p save
    ns_return 200 text/html "Registered user [ns_queryget username]!"
  } else {
    ns_return 200 text/html "The username [ns_queryget username] already exists!"
  }
}
