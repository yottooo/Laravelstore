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
  # Check, if we have some postings:
  #
  if {[Posting count] > 0} {
    #
    # Build result object containing the instance variable :postings,
    # which is a list of objects
    #
    set result [nx::Object new {
      set :postings [Posting find all -orderby ts]
    }]
    #
    # Set template for result, iterating over the postings with FOREACH
    #
    $result template set {
        <div class='row'>
          <FOREACH var='p' in=':postings' type='list'>
            <div class='col-6 col-lg-4'>
                <h2>@p;title@</h2>
                <p>@p;description@</p>
                <p><span class="label label-primary">@p;tags@</span></p>
                <p>Rating:<button class="rate" id='@p._id@'>+1</button>
                <%= [expr [join [ns_quotehtml [get_value2 p rating]]  +]]%></p>
                <a class="Posting" id='@p._id@'>See Content</a>
            </div><!--/span-->
          </FOREACH>
        </div>
    }

    #
    # Obtain the rendered HTML output
    #
    set html [$result template eval]

    ns_return 200 text/html $html
    set total [ns_time diff [ns_time get] $::t0]
    append ::timings "[format %5.3f [expr {[ns_time format $total]*1000}]]ms "
    $result destroy
  }
}
