#
# List all "postings" of the Business Informer datamodel in the
# database tutorial.
#

set t0 [ns_time get]

::nx::mongo::db connect -db "tutorial"

set timings "Timings: "

namespace eval ::qa {
   set html ""


    #
    # Build result object containing the instance variable :postings,
    # which is a list of objects
    #
    set result [nx::Object new {
      set Posting_id [ns_queryget id]
      puts $Posting_id
      set :posting [Posting find all -cond [list _id = $Posting_id] ]
    }]
    #
    # Set template for result, iterating over the postings with FOREACH
    #
    $result template set {
      <div id="sidecanvas" >
        <div class="col-12 sidebar-offcanvas" id="sidebar">
        <FOREACH var='p' in=':posting' type='list'>
          @p;obj@
        </FOREACH>
        </div>
      </div>
    }
    #
    # Obtain the rendered HTML output
    #
    set html [$result template eval]
    ns_return 200 text/html $html
    $result destroy

}
