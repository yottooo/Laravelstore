set result [ns_getcookie username ""]

if {$result eq ""} {
  ns_returnerror 404 "No Cookie found!"
} else {
  ns_return 200 text/html $result
}
