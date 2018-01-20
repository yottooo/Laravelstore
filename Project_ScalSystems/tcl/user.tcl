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
      set userName [ns_queryget username]
      puts $userName
      set :user [User find all -cond [list username = $userName] ]
    }]
    #
    # Set template for result, iterating over the postings with FOREACH
    #
    $result template set {
      <div id="sidecanvas" >
        <div class="col-6 col-md-3 sidebar-offcanvas" id="sidebar">
        <FOREACH var='p' in=':user' type='list'>
          <div class="panel panel-default">
            <div class="panel-heading">
              <h3>@p;username@</h3>
            </div>
            <!-- List group -->
            <ul class="list-group">
              <a href="#" class="list-group-item">Postings <span class="badge"><%= [expr {[::nx::var exists $p postings] ? [ns_quotehtml [get_value2 p postings]] : {0}}]%></span></a>
              <a href="#" class="list-group-item">Comments <span class="badge"><%= [expr {[::nx::var exists $p comments] ? [ns_quotehtml [get_value2 p postings]] : {0}}]%></span></a>
            </ul>
          </div>
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
