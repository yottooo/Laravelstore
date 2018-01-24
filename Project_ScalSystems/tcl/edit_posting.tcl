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

  set ::style {
      }


  #
  # Return a simple edit form built from the provided arguments.
  #
  proc posting-form {id what fields {context ""}} {
    if {$id eq ""} {ns_returnerror 400 "id missing"}
    set p [Posting find first -cond [list _id = $id]]
    foreach {label field size} $fields {
      append entries "<b>$label:</b> <input type='text' name='$field' size='$size' required> <br><br>\n"
    }
    ns_return 200 text/html [subst {
      $::style
      <div id="inputEntry" class="container">
      <h2> Adding $what to posting: </h2>
      <div class="panel panel-default">
        <!-- Default panel contents -->
          <div class="panel-body">

            <form id='entry'>
            <h2><em>[$p cget -title]</em><br></h2>
            <br>

            <input type='hidden' name='__id' value='$id'>
            <input type='hidden' name='__what' value='$what'>
            <input type='hidden' name='__action' value='validate'>
            <input type='hidden' name='__context' value='$context'>
            $entries
            <br>
            <input type='submit' id ='submitEntry'>
            </form>
          </div>
        </div>
      </div>
    }]
  }

  #
  # Locate the context with the posting structure and retrun the
  # corresponding object.
  #
  proc find-context {objs ctx} {
    foreach obj $objs {
      set ctx0 "[nsf::var::set $obj author]-[nsf::var::set $obj comment]"
      if {$ctx0 eq $ctx} {return $obj}
      if {[nsf::var::exists $obj replies]} {
	set r0 [find-context [nsf::var::set $obj replies] $ctx]
	if {$r0 ne ""} {return $r0}
      }
    }
    return ""
  }

  set id     [ns_queryget __id]
  set what   [ns_queryget __what "posting"]
  set action [ns_queryget __action]

  switch $what {

    posting {
      if {$action eq ""} {
	ns_return 200 text/html [subst {
	  $::style
    <div class="container">
    <h2> Adding new Question: </h2>
    <div class="panel panel-default">
      <!-- Default panel contents -->
        <div class="panel-body">
    	  <form id='entry'>
    	  <input type='hidden' name='__what' value='$what'>
    	  <input type='hidden' name='__action' value='validate'>
    	  Tags: <input type='text' name='tag' size="60" required> <br>
    	  Title: <input type='text' name='title' size="60" required><br><br>
        <p style="vertical-align: middle;">
        Description: <textarea name='description' style="height:200px; width:600px;resize:none" required></textarea> <br>
        </p>
    	  <input type='submit'>
	      </form>
    </div>
  </div>
</div>
	}]
      } else {
	set p [Posting new \
		   -title [ns_queryget title] \
		   -author [ns_queryget author] \
       -description [ns_queryget description] \
       -tag [ns_queryget tag] \
		   -ts [clock format [clock seconds] -format "%d-%b-%y %H:%M"]]
  set u [User find first -cond [list username = [ns_queryget author]]]
  $u postings add $p end
  $u save
	$p save
      }
    }

    tag {
      if {$action eq ""} {
	if {$id eq ""} {ns_returnerror 400 "id missing"}
	set p [Posting find first -cond [list _id = $id]]
	posting-form $id $what [list Tag tag 40]
      } else {
	set p [Posting find first -cond [list _id = $id]]
	$p tags add [ns_queryget tag] end
	$p save
      }
    }

    comment {
      if {$action eq ""} {
	if {$id eq ""} {ns_returnerror 400 "id missing"}
	set p [Posting find first -cond [list _id = $id]]
	posting-form $id $what [list Comment comment 80]
      } else {
	set p [Posting find first -cond [list _id = $id]]
	$p comments add [Comment new \
			     -author [ns_queryget author] \
			     -comment [ns_queryget comment]] end
	$p save
      }
    }

    reply {
      if {$action eq ""} {
	if {$id eq ""} {ns_returnerror 400 "id missing"}
	set p [Posting find first -cond [list _id = $id]]
	posting-form $id $what \
	    [list Reply reply 80] \
	    [ns_queryget __context]
      } else {
	set p [Posting find first -cond [list _id = $id]]
	set reply [Comment new \
		       -author [ns_queryget author] \
		       -comment [ns_queryget reply]]
	set obj [find-context [$p cget -comments] [ns_queryget __context]]
	ns_log notice "!!! find-context returns obj=$obj"
	if {$obj ne ""} {
	  ns_log notice "!!! adding reply to $obj of $p"
	  $obj replies add $reply end
	  $p save
	}
      }
    }
  }

}

ns_return 200 text/html "Okay"
