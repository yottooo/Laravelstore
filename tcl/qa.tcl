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
# The classes are kept in the namespace "qa" for better locality.  The
# created classes have a "qa::" prefix; they can be either adressed by
# their fully qualified names or inside a "namespace eval ::qa {...}"
# statement.
#
# This file contains as well the navigation structures for the "qa"
# application and the necessary templates for viewing with and without
# edit-controls.

::nx::mongo::db connect -db "tutorial"
nx::mongo::db drop collection postings
#? {::nx::mongo::db collection tutorial.persons} "mongoc_collection_t:0"


namespace eval qa {
  #
  # The instances of the class "Comment" are embedded in a posting
  # (property "comments") as well as in an comment itself (property
  # "replies"). All comments are in this example multivalued and
  # incremental (i.e. one can use slot methods "... add ...").
  #
  nx::mongo::Class create Comment {
    :property author:required
    :property comment:required
    :property -incremental replies:embedded,type=::qa::Comment,0..n
  }

  nx::mongo::Class create Posting {
    :index tags
    :property title:required
    :property author:required
    :property description:required
    :property ts:required
    :property -incremental comments:embedded,type=::qa::Comment,0..n
    :property -incremental {tags:0..n ""}
    :property -incremental {rating:0..n "0"}
  }

  nx::mongo::Class create User {
    :property username:required
    :property email:required
    :property password:required
    :property -incremental postings:embedded,type=::qa::Posting,0..n
    :property -incremental comments:embedded,type=::qa::Comment,0..n
  }

  #
  # Helper procs for navigation and introspection
  #
  proc navigation-bar {} {
    return {
      <nav class="navbar navbar-inverse navbar-fixed-top">
    		<div class="container">
    			<div class="navbar-header">
    				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
    				<span class="sr-only">Toggle navigation</span>
    				<span class="icon-bar"></span>
    				<span class="icon-bar"></span>
    				<span class="icon-bar"></span>
    				</button>
    				<a class="navbar-brand"><img src="logo.png" style="width:110px;height:27px;margin:0px;padding:0px"></a>
    			</div>
    			<div id="navbar" class="navbar-collapse collapse">
    				<ul class="nav navbar-nav">
    				<li><a href='list_questions.adp'>List Questions</a> </li>
    				<li><a href='edit_questions.adp'>Edit Questions</a></a></li>
    				</ul>
    			</div><!--/.nav-collapse -->
    		</div>
    	</nav>
    }
  }

  proc footer {} {
    return {
      <a href='mongo-insert1.tcl'>insert first</a> &sdot;
      <a href='mongo-drop.tcl'>drop all</a> &sdot;
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
  <div class="panel panel-default">
    <!-- Default panel contents -->
      <div class="panel-body">
        <h3> @:title@ </h3><span class="label label-primary"> @:tags@ </span>
        <h4>@:description@</h4>
        <small class="text-muted"><b>@:author@</b> @:ts@</small>
        <hr>
        <FOREACH var='c' in=':comments' type='list'>@c;obj@
        </FOREACH><br/>
    </div>
  </div>
  }]

  Comment template set {
    <div class="well well-sm">
    @:comment@ <small class="text-muted"><b> - @:author@</b></small>
    </div>
    <ul>
    <FOREACH var='r' in=':replies' type='list'>
      <li>@r;obj@</li>
    </FOREACH>
    </ul>
  }

  User template set {
    <div class="well well-sm">
    @:username@
    @:email@
    @:password@
    @:postings@
    @:comments@
    </div>
  }


  #
  # edit templates
  #

  proc add-field {what {context ""}} {
    #puts stderr "add-field $what $context"
    return [subst {<a title="add $what"
      href='mongo-new.tcl?__what=$what&__id=@::_id@&__context=$context'>$what</a>}]
  }

  # [add-field tag]
  Posting template set -name edit [subst {
    <div class="panel panel-default">
    <!-- Default panel contents -->
      <div class="panel-body">
        <% set ::_id \[set :_id\] %>
        <h3> @:title@ </h3><span class="label label-primary"> @:tags@ </span>
        <h4>@:description@</h4>
        <small class="text-muted"><b>@:author@</b> @:ts@</small>
        <hr>
        [add-field comment] <hr>
        <FOREACH var='c' in=':comments' type='list'>@c;obj;edit@
        </FOREACH>
      </div>
    </div>
  }]

  Comment template set -name edit [subst {
    <div class="well well-sm">
    @:comment@ <small class="text-muted"><b> - @:author@</b></small>
    [add-field reply @:author@-@:comment@]
    </div>

    <ul>
    <FOREACH var='r' in=':replies' type='list'>
      <li>@r;obj;edit@</li>
    </FOREACH>
    </ul>
  }]

}
