<?php

include 'Router.php';


//define your route. This is main page route. for example www.example.com
Route::add('/', function(){

    //define which page you want to display while user hit main page. 
    include('home.php');
});


// route for www.example.com/join
Route::add('/health', function(){
    include('health.php');
});





//method for execution routes    
Route::submit();