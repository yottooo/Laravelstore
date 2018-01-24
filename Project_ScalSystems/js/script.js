$(document).ready(function(){

    $('a').on('click', function(e){
     e.preventDefault( );
     var pageRef = $(this).attr('href');
     console.log("hierss")
     callPage(pageRef)
   });

   $('body').on('click','.Posting', function(e){
    e.preventDefault( );
    var PostingID = $(this).attr('id');
    loadPosting(PostingID)
  });

  $('body').on('click','.editEntry', function(e){
   e.preventDefault( );
   var PostingID = $(this).attr('id');
   var what = $(this).attr('what');
   var context = $(this).attr('context');
   console.log(PostingID +" "+ what +" "+ context);

   $.ajax({
     url: 'tcl/edit_posting.tcl?__id='+PostingID+'&__what='+what+'&__context='+context,
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
 });

 loadContent();

 function loadContent(){
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

    // this is the id of the form
    $("#content").submit('#entry',function(e) {
        console.log($("#entry").serialize());
       $.ajax({
              type: "POST",
              url: "tcl/edit_posting.tcl",
              data: $("#entry").serialize(), // serializes the form's elements.
              success: function(data)
              {    console.log(data)
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
   changeRating(PostingID)
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
    };


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
            }else if (pageRefInput == str.startsWith('loadPosting')) {
                  console.log("hh")
                  var id = pageRefInput.replace('loadPosting?id=','')
                  loadPosting(id)
            } else {
              $('.content').html(response);
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
});
