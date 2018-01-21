$(document).ready(function(){
$(".registerUser").hide();
  var dialog, form,

  // From http://www.whatwg.org/specs/web-apps/current-work/multipage/states-of-the-type-attribute.html#e-mail-state-%28type=email%29
  emailRegex = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/,
  username = $( "#username" ),
  email = $( "#email" ),
  password = $( "#password" ),
  allFields = $( [] ).add( username ).add( email ).add( password ),
  tips = $( ".validateTips" );

function updateTips( t ) {
  tips
    .text( t )
    .addClass( "ui-state-highlight" );
  setTimeout(function() {
    tips.removeClass( "ui-state-highlight", 1500 );
  }, 500 );
}

function checkLength( o, n, min, max ) {
  if ( o.val().length > max || o.val().length < min ) {
    o.addClass( "ui-state-error" );
    updateTips( "Length of " + n + " must be between " +
      min + " and " + max + "." );
    return false;
  } else {
    return true;
  }
}

function checkRegexp( o, regexp, n ) {
  if ( !( regexp.test( o.val() ) ) ) {
    o.addClass( "ui-state-error" );
    updateTips( n );
    return false;
  } else {
    return true;
  }
}

  function addUser() {
      var valid = true;
      allFields.removeClass( "ui-state-error" );

      valid = valid && checkLength( username, "username", 3, 16 );
      valid = valid && checkLength( email, "email", 6, 80 );
      valid = valid && checkLength( password, "password", 5, 16 );

      valid = valid && checkRegexp( username, /^[a-z]([0-9a-z_\s])+$/i, "Username may consist of a-z, 0-9, underscores, spaces and must begin with a letter." );
      valid = valid && checkRegexp( email, emailRegex, "eg. ui@jquery.com" );
      valid = valid && checkRegexp( password, /^([0-9a-zA-Z])+$/, "Password field only allow : a-z 0-9" );

      if ( valid ) {
        $( "#users tbody" ).append( "<tr>" +
          "<td>" + username.val() + "</td>" +
          "<td>" + email.val() + "</td>" +
          "<td>" + password.val() + "</td>" +
        "</tr>" );
      }
      return valid;
  }

   // this is the id of the form
   $("#formLogin").submit(function(e) {
      console.log("Submit stuff");

      $.ajax({
             type: "POST",
             url: "tcl/user.tcl",
             data: $("#formLogin").serialize(), // serializes the form's elements.
             success: function(data)
             {    console.log(data)
                  $('#sidecanvas').html(data); // show response from the php script.
             },error: function( error ){
                 alert("Unable to login! Please check username and password!");
                 console.log('the page was NOT loaded', error);
             },

             complete: function( xhr, status ) {
               console.log('The request is complete!');
             }
           });

       e.preventDefault(); // avoid to execute the actual submit of the form.
   });

   function loginUser(username, password){
     console.log(JSON.stringify({"username" : username, "password" : password }))
     $.ajax({
            type: "POST",
            url: "tcl/user.tcl",
            data: "username=" + username + "&password=" + password, // serializes the form's elements.
            success: function(data)
            {
                 $('#sidecanvas').html(data); // show response from the php script.
            }
          });
   }


   // this is the id of the form
   $("#registerUser").submit('.registerUser',function(e) {
       $.ajax({
              type: "POST",
              url: "tcl/register.tcl",
              data: $("#formID").serialize(), // serializes the form's elements.
              success: function(data)
              { console.log('the page was NOasdT loaded', data);
                  loginUser( $("#formID #username").val(), $("#formID #password").val());
              },
              error: function( error ){
                  alert("Error!")
                  console.log('the page was NOT loaded', error);
              },

              complete: function( xhr, status ) {
                console.log('The request is complete!');
              }
            });
       e.preventDefault(); // avoid to execute the actual submit of the form.
   });

   $( "#openRegisterUser" ).button().click(function() {
      $(".registerUser").show();
      $('#content').html("");
   });
   $("#dialogWrapper").hide();

} );
