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
    :property text:required
    :property ts:required
    :property -incremental comments:embedded,type=::bi::Comment,0..n
    :property -incremental {tags:0..n ""}
    :property -incremental {rating:0..n ""}
  }

  #
  # Helper procs for navigation and introspection
  #
  proc navigation-bar {} {
    return {

      <a href='biindex.adp'>list</a> &sdot;
      <a href='biedit.adp'>edit</a> &sdot;
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
    @:ts@: <b>@:author@</b> posts: <em>@:title@</em><em>@:text@</em> <br>
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
    <% set ::_id \[set :_id\] %>
    @:ts@: <b>@:author@</b> posts: <em>@:title@</em> [add-field comment]<br>
    <ul><FOREACH var='c' in=':comments' type='list'><li>@c;obj;edit@</li>
    </FOREACH></ul>
    tags: @:tags@ [add-field tag]<br>
    rating: @:rating@ [add-field rating]<br>
  }]

  Comment template set -name edit [subst {
    <b>@:author@</b> comments: <em>'@:comment@'</em>
    [add-field reply @:author@-@:comment@]
    <ul><FOREACH var='r' in=':replies' type='list'><li>reply: @r;obj;edit@</li></FOREACH></ul>
  }]

}
