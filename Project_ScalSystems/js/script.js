$(document).ready(function(){

    checkCookie();
    loadContent();
    //callPage("sidecanvas/login.html");

    $('a').on('click', function(e){
     e.preventDefault( );
     var pageRef = $(this).attr('href');
     callPage(pageRef)
   });

   $('body').on('click','.Posting', function(e){
    e.preventDefault( );
    var PostingID = $(this).attr('id');
    loadPosting(PostingID)
  });

  $('body').on('click','#newQuestion', function(e){
   e.preventDefault( );

   $.ajax({
     url: 'tcl/edit_posting.tcl',
     type: "GET",
     dataType : 'text',
     success: function( response ){
       $('#edit').html(response);
       $('#content').html("");

       console.log('the page was loaded', response);
     },
     error: function( error ){
         $('#content').html('The page was NOT loaded');
         console.log('the page was NOT loaded', error);
     },

     complete: function( xhr, status ) {
       console.log('The request is complete!');
     }
   });
 });

  $('#edit').on('click','.editEntry', function(e){
   e.preventDefault( );
   var PostingID = $(this).attr('id');
   var what = $(this).attr('what');
   var context = $(this).attr('context');
   var user = $("#sidecanvas h3").val();

   $.ajax({
     url: 'tcl/edit_posting.tcl?__id='+PostingID+'&__what='+what+'&__context='+context,
     type: "GET",
     dataType : 'text',
     success: function( response ){
       $('#edit').html(response);
       $('#content').html("");
       console.log('the page was loaded', response);
     },
     error: function( error ){
         $('#content').html('The page was NOT loaded');
         console.log('the page was NOT loaded', error);
     },

     complete: function( xhr, status ) {
       console.log('The request is complete!');
     }
   });
 });



    // this is the id of the form
    $("#edit").submit('#entry',function(e) {
        var username= $('#sidecanvas #currentUser').html();
       $.ajax({
              type: "POST",
              url: "tcl/edit_posting.tcl",
              data: $("#entry").serialize()+"&author="+username, // serializes the form's elements.
              success: function(data)
              {    console.log(data)
                   $('#content').html("");
                   loadContent(); // show response from the php script.
              },error: function( error ){
                  console.log(error)
                  console.log('the page was NOT loaded', error);
              },

              complete: function( xhr, status ) {
                console.log('The request is complete!');
              }
            });
        e.preventDefault(); // avoid to execute the actual submit of the form.
    });

  //When you click the button
  $('body').on('click','.rate', function(e){
   e.preventDefault( );
   var PostingID = $(this).attr('id');
   changeRating(PostingID);
 });

   function changeRating(id){
     $.ajax({
       url: 'tcl/rating.tcl?id='+id,
       type: "GET",
       success: function( response ){
         $('rate').html(response);
         console.log('the page was loaded', response);
       },
       error: function( error ){
           $('#content').html('The page was NOT loaded');
           console.log('the page was NOT loaded', error);
       },

       complete: function( xhr, status ) {
         console.log('The request is complete!');
       }
     });

     $.ajax({
       url: 'tcl/content.tcl',
       type: "GET",
       dataType : 'text',
       success: function( response ){
         $('#content').html(response);
         console.log('the page was loaded', response);
       },
       error: function( error ){
           $('#content').html('The page was NOT loaded');
           console.log('the page was NOT loaded', error);
       },

       complete: function( xhr, status ) {
         console.log('The request is complete!');
       }
     });
   }

   function loadPosting(id){
        $.ajax({
          url: 'tcl/loadPosting.tcl?id='+id,
          type: "GET",
          success: function( response ){
            $('#edit').html(response);
            $('#content').html("");

            console.log('the page was loaded', response);
          },
          error: function( error ){
              $('#content').html('The page was NOT loaded');
              console.log('the page was NOT loaded', error);
          },

          complete: function( xhr, status ) {
            console.log('The request is complete!');
          }
        });
    };

    $("#sidecanvas").on('click',"#logout",function() {
       logoutUser();
    });
});

function loadContent(){
   $.ajax({
     url: 'tcl/content.tcl',
     type: "GET",
     dataType : 'text',
     success: function( response ){
       $('#edit').html(response);
       $('#content').html("");
       console.log('the page was loaded', response);
     },
     error: function( error ){
         $('#content').html('The page was NOT loaded');
         console.log('the page was NOT loaded', error);
     },

     complete: function( xhr, status ) {
       console.log('The request is complete!');
     }
   });
 }

 function checkCookie(){
    $.ajax({
      url: 'tcl/checkCookie.tcl',
      type: "GET",
      dataType : 'text',
      success: function( response ){
        var user = $("#sidecanvas h3").val();
        $.ajax({
               type: "GET",
               url: "tcl/userLoggedIn.tcl",
               success: function(data)
               {
                    $('#sidecanvas').html(data); // show response from the php script.
                    loadContent();
               },
               error: function( error ){

                   console.log('the page was NOT loaded', error);
               },
               complete: function( xhr, status ) {
                 console.log('The request is complete!');
               }
             });
      },
      error: function( error ){
          callPage("sidecanvas/login.html");
          console.log('the page was NOT loaded', error);
      },
      complete: function( xhr, status ) {
        console.log('The request is complete!');
      }
    });
  }

function logoutUser(){
  $.ajax({
         type: "GET",
         url: "tcl/logoutUser.tcl",
         success: function(data)
         {
              location.reload();
         },
         error: function( error ){

             console.log('the page was NOT loaded', error);
         },
         complete: function( xhr, status ) {
           console.log('The request is complete!');
         }
       });
}


 function callPage(pageRefInput){
     $.ajax({
       url: pageRefInput,
       type: "GET",
       dataType : 'text',
       success: function( response ){
         if(pageRefInput == 'sidecanvas/login.html'){
           $('#sidecanvas').html(response);
         } else if(pageRefInput == 'index.html') {
           location.reload();
         }else if (pageRefInput.startsWith('loadPosting')) {
               var id = pageRefInput.replace('loadPosting?id=','')
               loadPosting(id)
         } else if (pageRefInput == 'register.html') {
               $('#content').html(response);
         } else{

         }
           console.log('the page was loaded', response);
       },

       error: function( error ){
           console.log('the page was NOT loaded', error);
       },

       complete: function( xhr, status ) {
         console.log('The request is complete!');
       }
     });
 };
