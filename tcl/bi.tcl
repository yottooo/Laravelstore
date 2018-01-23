package require nx::mongo

#
# Make sure to load oo-templating before this file.
#
if {[info command ::compile_template] eq ""} {source [file dirname [info script]]/oo-templating.tcl}

######################################################################
# Create the application classes based on the "Business Insider" data
# model. See e.g.
# http://www.slideshare.net/mongodb/nosql-the-shift-to-a-nonrelational-world
#
# The classes are kept in the namespace "bi" for better locality.  The
# created classes have a "bi::" prefix; they can be either adressed by
# their fully qualified names or inside a "namespace eval ::bi {...}"
# statement.
#
# This file contains as well the navigation structures for the "bi"
# application and the necessary templates for viewing with and without
# edit-controls.

::nx::mongo::db connect -db "tutorial"
nx::mongo::db drop collection postings
#? {::nx::mongo::db collection tutorial.persons} "mongoc_collection_t:0"


namespace eval bi {
  #
  # The instances of the class "Comment" are embedded in a posting
  # (property "comments") as well as in an comment itself (property
  # "replies"). All comments are in this example multivalued and
  # incremental (i.e. one can use slot methods "... add ...").
  #
  nx::mongo::Class create Comment {
    :property author:required
    :property comment:required 
    :property -incremental replies:embedded,type=::bi::Comment,0..n
  }
    
  nx::mongo::Class create Posting {
    :index tags
    :property title:required
    :property author:required
	:property description:required
    :property ts:required
    :property -incremental comments:embedded,type=::bi::Comment,0..n
    :property -incremental {tags:0..n ""}
  }

  #
  # Helper procs for navigation and introspection
  #
  proc navigation-bar {} {
    return {
      <nav class="navbar navbar-fixed-top navbar-inverse" role="navigation">
		  <div class="container-fluid">
			<!-- Brand and toggle get grouped for better mobile display -->
			<div class="navbar-header">
			  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#menu" aria-expanded="false">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			  </button>
			  <a class="navbar-brand" href="#">WU ScalableSystems Engineering</a>
			</div>

			<!-- Collect the nav links, forms, and other content for toggling -->
			<div class="collapse navbar-collapse" id="menu">
			  <ul class="nav navbar-nav">
				<li><a href='mongo-list.adp'>List</a></li>
    			<li><a href='mongo-edit.adp'>Edit</a></li>
				<li><a href='mongo-insert1.tcl'>Insert First</a></li>
				<li><a href='mongo-drop.tcl'>Drop All</a></li>
			  </ul>
			</div><!-- /.navbar-collapse -->
		  </div><!-- /.container-fluid -->
		</nav>
    }
  }

  proc classes {} {
    set classInfo "MongoDB Classes:\n"
    foreach cl [lsort [nx::mongo::Class info instances]] {
      append classInfo [subst {
	class $cl
	  variables:       [$cl pretty_variables]
	instances in db: [$cl count]
	}]
    }
    return $classInfo
  }

  #
  # default templates
  #

  ns_log notice [Posting template set {
    @:ts@:  <h4>@:title@</h4> <br>
	<h5>@:description@</h5> <br>
	<b>@:author@</b> <br>
    <ul><FOREACH var='c' in=':comments' type='list'><li>@c;obj@</li>
    </FOREACH></ul>
    tags: @:tags@<br>
  }]

  Comment template set {
    <b>@:author@</b> comments: <em>'@:comment@'</em>
    <ul><FOREACH var='r' in=':replies' type='list'><li>reply: @r;obj@</li></FOREACH></ul>
  }

  #
  # edit templates
  #
    
  proc add-field {what {context ""}} {
    #puts stderr "add-field $what $context"
    return [subst {<a title="add $what" 
      href='mongo-new.tcl?__what=$what&__id=@::_id@&__context=$context'>\[+\]</a>}]
  }

  Posting template set -name edit [subst {
	@:ts@:  <h4>@:title@</h4> <br>
	<h5>@:description@</h5> <br>
	<b>@:author@</b> <br>
    <% set ::_id \[set :_id\] %>
    [add-field comment]<br>
    <ul><FOREACH var='c' in=':comments' type='list'><li>@c;obj;edit@</li>
    </FOREACH></ul>
    tags: @:tags@ [add-field tag]<br>
  }]

  Comment template set -name edit [subst {
    <b>@:author@</b> comments: <em>'@:comment@'</em>
    [add-field reply @:author@-@:comment@]
    <ul><FOREACH var='r' in=':replies' type='list'><li>reply: @r;obj;edit@</li></FOREACH></ul>
  }]

}
