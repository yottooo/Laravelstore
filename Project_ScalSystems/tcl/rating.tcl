::nx::mongo::db connect -db "tutorial"

#
# Update manager for the "Business Informer" example.
#
# All edit operations from the business informer are implemented via
# this file.  Since we want to add content to arbitrary positions in
# the posting tree, we have to pass a "context" that points to the
# right entry, to the edit-operation and we have to evaluate this when
# the form is submitted.
#
# The submitted form is distinguished from the prompt (here the empty
# form, but it can/should be extended to provide the default values)
# via the hidden form field "__action", which is set to
# e.g. "validate". For now, we perform no validation here.
namespace eval ::qa {

  #
  # Return a simple edit form built from the provided arguments.
  #
  # Locate the context with the posting structure and retrun the
  # corresponding object.

  set Posting_id [ns_queryget id]
  puts $Posting_id
  set p [Posting find all -cond [list _id = $Posting_id] ]
  
	$p rating add 1 end
	$p save
  set
  ns_return 200 text/html $test
}
