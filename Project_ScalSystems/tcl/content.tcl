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
            <div class="panel panel-default">
              <!-- Default panel contents -->
                <div class="panel-body " style="height: 300px;">
                <h3>@p;title@</h3>
                <p style="overflow:hidden;height: 100px;word-wrap:break-word;">@p;description@</p>
                <p><span class="label label-primary">@p;tags@</span></p>
                <p><%= [expr [join [ns_quotehtml [get_value2 p votes]]  +]]%></p>
                <h4> Votes: 0  Answers: 0 </h4>
                <a class="Posting" id='@p._id@'>See Content</a>
              </div>
              </div>
            </div>
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
